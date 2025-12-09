#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <buddy_pmm.h>

/*
 * Function: Buddy-based physical page allocator
 * ---------------------------------------------
 * Implements a classic buddy allocator on page granularity.
 * - Manages free blocks in orders, each block size = (1 << order) pages
 * - Uses per-order free lists; head page of a free block has PG_property=1
 * - Stores the order in Page.property for the head page
 * - Allocates exactly n contiguous pages by carving a prefix from a larger buddy block and
 *   returning the first n pages; the remaining suffix is reinserted into free lists with merging
 * - Frees a contiguous n-page region by splitting into maximal aligned buddy blocks and merging
 *
 * Parameters meaning for key functions:
 * - buddy_init(): initialize internal structures
 * - buddy_init_memmap(base, n): add a contiguous [base, base+n) region into buddy as free
 * - buddy_alloc_pages(n): allocate n contiguous pages, return base Page* or NULL
 * - buddy_free_pages(base, n): free n contiguous pages starting at base
 * - buddy_nr_free_pages(): return total number of free pages
 * - buddy_check(): self-check correctness (allocation, free, merge, split)
 */

#define BUDDY_MAX_ORDER  18

typedef struct {
    list_entry_t free_list;
    unsigned int nr_free;
} buddy_area_t;

static buddy_area_t buddy_area[BUDDY_MAX_ORDER + 1];
static size_t buddy_total_free = 0;

#define order_free_list(order) (buddy_area[(order)].free_list)
#define order_nr_free(order)   (buddy_area[(order)].nr_free)

static inline size_t page_index(struct Page *p) { return (size_t)(p - pages); }
static inline struct Page *index_to_page(size_t idx) { return pages + idx; }
static inline size_t order_block_pages(size_t order) { return ((size_t)1u << order); }

static void buddy_init(void);
static void buddy_init_memmap(struct Page *base, size_t n);
static struct Page *buddy_alloc_pages(size_t n);
static void buddy_free_pages(struct Page *base, size_t n);
static size_t buddy_nr_free_pages(void);
static void buddy_check(void);

/*
 * Function: try_coalesce_and_insert
 * ---------------------------------
 * Merge a free block with its buddy iteratively, then insert into the final order list.
 * Inputs: base - head page of the block, order - current order of the block
 * Effects: updates per-order and total counters appropriately
 */
static void try_coalesce_and_insert(struct Page *base, unsigned int order) {
    size_t idx = page_index(base);
    while (order < BUDDY_MAX_ORDER) {
        size_t buddy_idx = idx ^ order_block_pages(order);
        struct Page *buddy_head = index_to_page(buddy_idx);
        if (PageProperty(buddy_head) && buddy_head->property == order) {
            list_del(&(buddy_head->page_link));
            order_nr_free(order) -= order_block_pages(order);
            ClearPageProperty(buddy_head);
            buddy_head->property = 0;
            if (buddy_idx < idx) {
                base = buddy_head;
                idx = buddy_idx;
            }
            order++;
            continue;
        }
        break;
    }
    base->property = order;
    SetPageProperty(base);
    list_add(&order_free_list(order), &(base->page_link));
    order_nr_free(order) += order_block_pages(order);
}

/*
 * Function: insert_region
 * -----------------------
 * Insert and merge a contiguous region [base, base+n) into buddy free lists.
 * Greedy split into maximal aligned blocks at each step, then coalesce upward.
 */
static void insert_region(struct Page *base, size_t n) {
    size_t idx = page_index(base);
    while (n > 0) {
        unsigned int order = 0;
        size_t max_fit = 1;
        while (order < BUDDY_MAX_ORDER) {
            size_t blk = order_block_pages(order + 1);
            if (blk > n) break;
            if ((idx & (blk - 1)) != 0) break;
            order++;
            max_fit = blk;
        }
        try_coalesce_and_insert(index_to_page(idx), order);
        idx += max_fit;
        n   -= max_fit;
    }
}

/*
 * Function: carve_suffix_as_free
 * ------------------------------
 * After allocating a prefix [base, base+n) from a block [base, base+s),
 * return the suffix [base+n, base+s) back to the buddy system as free.
 */
static void carve_suffix_as_free(struct Page *base, size_t n, size_t s) {
    if (n < s) {
        struct Page *suffix = base + n;
        size_t suffix_pages = s - n;
        insert_region(suffix, suffix_pages);
    }
}

static void buddy_init(void) {
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        list_init(&order_free_list(i));
        order_nr_free(i) = 0;
    }
    buddy_total_free = 0;
}

static void buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        p->flags = 0;
        p->property = 0;
        set_page_ref(p, 0);
    }
    insert_region(base, n);
    buddy_total_free += n;
}

static struct Page *buddy_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > buddy_total_free) {
        return NULL;
    }
    // Find minimal order with block size >= n and non-empty free list (or larger order to carve)
    unsigned int want_order = 0;
    while ((order_block_pages(want_order) < n) && want_order < BUDDY_MAX_ORDER) {
        want_order++;
    }
    unsigned int found_order = want_order;
    while (found_order <= BUDDY_MAX_ORDER && list_empty(&order_free_list(found_order))) {
        found_order++;
    }
    if (found_order > BUDDY_MAX_ORDER) {
        return NULL;
    }

    // Pop one block from found_order
    list_entry_t *le = list_next(&order_free_list(found_order));
    struct Page *block = le2page(le, page_link);
    list_del(&(block->page_link));
    order_nr_free(found_order) -= order_block_pages(found_order);
    ClearPageProperty(block);
    block->property = 0;

    size_t s = order_block_pages(found_order);
    carve_suffix_as_free(block, n, s);

    struct Page *p = block;
    for (size_t i = 0; i < n; i++, p++) {
        ClearPageProperty(p);
        p->property = 0;
    }

    buddy_total_free -= n;
    return block;
}

static void buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    insert_region(base, n);
    buddy_total_free += n;
}

static size_t buddy_nr_free_pages(void) { return buddy_total_free; }

static void basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    buddy_area_t saved[BUDDY_MAX_ORDER + 1];
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        saved[i] = buddy_area[i];
    }
    size_t total_saved = buddy_total_free;

    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        list_init(&order_free_list(i));
        order_nr_free(i) = 0;
    }
    size_t total_store = buddy_total_free;
    buddy_total_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(buddy_total_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(buddy_total_free >= 1);

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(buddy_total_free == 0);

    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        order_free_list(i) = saved[i].free_list;
        order_nr_free(i) = saved[i].nr_free;
    }
    buddy_total_free = total_saved;

    free_page(p);
    free_page(p1);
    free_page(p2);
    (void)total_store;
}

static void buddy_check(void) {
    size_t total = 0;
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        list_entry_t *le = &order_free_list(i);
        while ((le = list_next(le)) != &order_free_list(i)) {
            struct Page *p = le2page(le, page_link);
            assert(PageProperty(p));
            assert(p->property == i);
            total += order_block_pages(i);
        }
    }
    assert(total == buddy_nr_free_pages());

    basic_check();

    size_t before = buddy_nr_free_pages();
    struct Page *q = alloc_pages(3);
    assert(q != NULL);
    assert(buddy_nr_free_pages() + 3 == before);
    free_pages(q, 3);
    assert(buddy_nr_free_pages() == before);

    struct Page *r = alloc_pages(8);
    assert(r != NULL);
    struct Page *r2 = r + 3;
    free_pages(r2, 5);
    free_pages(r, 3);

    assert(buddy_nr_free_pages() == before);

    // extra: isolated mini arena tests
    size_t g_before = buddy_nr_free_pages();
    struct Page *arena = alloc_pages(32);
    assert(arena != NULL);
    buddy_area_t saved2[BUDDY_MAX_ORDER + 1];
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        saved2[i] = buddy_area[i];
    }
    size_t saved_total2 = buddy_total_free;
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        list_init(&order_free_list(i));
        order_nr_free(i) = 0;
    }
    buddy_total_free = 0;
    insert_region(arena, 32);
    buddy_total_free = 32;

    struct Page *b0 = alloc_pages(4);
    struct Page *b1 = alloc_pages(4);
    struct Page *b2 = alloc_pages(4);
    struct Page *b3 = alloc_pages(4);
    assert(b0 && b1 && b2 && b3);
    struct Page *d0 = alloc_pages(4);
    struct Page *d1 = alloc_pages(4);
    struct Page *d2 = alloc_pages(4);
    struct Page *d3 = alloc_pages(4);
    assert(d0 && d1 && d2 && d3);
    free_pages(b0 + 1, 2);
    assert(alloc_pages(3) == NULL);
    struct Page *t = alloc_pages(3);
    assert(t == NULL);
    free_page(b0);
    free_page(b0 + 3);
    struct Page *p4 = alloc_pages(4);
    assert(p4 == b0);
    free_pages(p4, 4);
    free_pages(b1, 4);
    free_pages(b2, 4);
    free_pages(b3, 4);

    free_pages(d0, 4);
    free_pages(d1, 4);
    free_pages(d2, 4);
    free_pages(d3, 4);
    struct Page *c0 = alloc_pages(8);
    assert(c0 != NULL);
    free_pages(c0, 4);
    free_pages(c0 + 4, 4);
    struct Page *c = alloc_pages(8);
    assert(c == c0);
    free_pages(c, 8);

    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        list_entry_t *le = &order_free_list(i);
        for (list_entry_t *a = list_next(le); a != le; a = list_next(a)) {
            struct Page *pa = le2page(a, page_link);
            size_t idxa = page_index(pa);
            size_t bs = order_block_pages(i);
            size_t bidx = idxa ^ bs;
            for (list_entry_t *b = list_next(le); b != le; b = list_next(b)) {
                struct Page *pb = le2page(b, page_link);
                size_t idxb = page_index(pb);
                assert(!(idxb == bidx));
            }
        }
    }

    struct Page *drain[64];
    size_t dn = 0;
    struct Page *u;
    while ((u = alloc_pages(1)) != NULL && dn < 64) {
        drain[dn++] = u;
    }

    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        order_free_list(i) = saved2[i].free_list;
        order_nr_free(i) = saved2[i].nr_free;
    }
    buddy_total_free = saved_total2;

    free_pages(arena, 32);
    assert(buddy_nr_free_pages() == g_before);
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};

