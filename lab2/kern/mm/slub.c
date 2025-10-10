#include <slub.h>
#include <pmm.h>
#include <string.h>
#include <stdio.h>

/*
 * Function: Simplified SLUB allocator
 * -----------------------------------
 * Two-layer design with power-of-two size classes; freelist is embedded.
 * slub_init(): initialize caches
 * kmalloc(size): allocate size bytes
 * kfree(ptr): free pointer
 * slub_check(): basic tests
 */

typedef struct slab_page {
    struct Page *page;
    void *free_head;
    unsigned int inuse;
    unsigned int capacity;
    struct slab_page *next;
} slab_page_t;

typedef struct {
    size_t object_size;
    slab_page_t *partial;
    slab_page_t *full;
} kmem_cache_t;

#define SLUB_NUM_CLASSES 8
static kmem_cache_t caches[SLUB_NUM_CLASSES];
static const size_t class_sizes[SLUB_NUM_CLASSES] = {16, 32, 64, 128, 256, 512, 1024, 2048};

typedef struct large_hdr {
    uint32_t magic;
    uint32_t pages;
    struct Page *page;
} large_hdr_t;

#define LARGE_MAGIC 0x4C52474C

#define SLUB_SP_MAX 256
static slab_page_t sp_pool[SLUB_SP_MAX];
static int sp_freelist_head = -1;

static slab_page_t *alloc_sp(void) {
    if (sp_freelist_head < 0) return NULL;
    int idx = sp_freelist_head;
    sp_freelist_head = (int)(uintptr_t)sp_pool[idx].next;
    sp_pool[idx].next = NULL;
    return &sp_pool[idx];
}

static void free_sp(slab_page_t *sp) {
    int idx = (int)(sp - sp_pool);
    sp->next = (slab_page_t *)(uintptr_t)sp_freelist_head;
    sp_freelist_head = idx;
}

static inline size_t align_up(size_t x, size_t a) {
    return (x + a - 1) & ~(a - 1);
}

static int pick_cache(size_t size) {
    size = size < sizeof(void*) ? sizeof(void*) : size;
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
        if (class_sizes[i] >= size) return i;
    }
    return -1;
}

static slab_page_t *new_slab_page(kmem_cache_t *cache) {
    struct Page *pg = alloc_page();
    if (pg == NULL) return NULL;
    void *mem = (void *)(page2pa(pg) + PHYSICAL_MEMORY_OFFSET);
    size_t obj_size = cache->object_size;
    size_t objs = PGSIZE / obj_size;
    if (objs == 0) {
        free_page(pg);
        return NULL;
    }
    void *head = NULL;
    for (size_t i = 0; i < objs; i++) {
        void **slot = (void **)((char *)mem + i * obj_size);
        *slot = head;
        head = slot;
    }
    slab_page_t *sp = alloc_sp();
    if (sp == NULL) {
        free_page(pg);
        return NULL;
    }
    sp->page = pg;
    sp->free_head = head;
    sp->inuse = 0;
    sp->capacity = (unsigned int)objs;
    sp->next = cache->partial;
    cache->partial = sp;
    return sp;
}

void slub_init(void) {
    sp_freelist_head = -1;
    for (int i = SLUB_SP_MAX - 1; i >= 0; i--) {
        sp_pool[i].next = (slab_page_t *)(uintptr_t)sp_freelist_head;
        sp_freelist_head = i;
    }
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
        caches[i].object_size = class_sizes[i];
        caches[i].partial = NULL;
        caches[i].full = NULL;
    }
}

void *kmalloc(size_t size) {
    int idx = pick_cache(size);
    if (idx < 0) {
        size_t bytes = align_up(size, PGSIZE);
        size_t pages_need = bytes / PGSIZE;
        struct Page *pg = alloc_pages(pages_need);
        if (pg == NULL) return NULL;
        void *kva = (void *)(page2pa(pg) + PHYSICAL_MEMORY_OFFSET);
        if (bytes < sizeof(large_hdr_t)) {
            bytes = sizeof(large_hdr_t);
        }
        large_hdr_t *hdr = (large_hdr_t *)kva;
        hdr->magic = LARGE_MAGIC;
        hdr->pages = (uint32_t)pages_need;
        hdr->page = pg;
        return (void *)((char *)kva + sizeof(large_hdr_t));
    }
    kmem_cache_t *cache = &caches[idx];
    if (cache->partial == NULL) {
        if (new_slab_page(cache) == NULL) return NULL;
    }
    slab_page_t *sp = cache->partial;
    void *obj = sp->free_head;
    if (obj == NULL) {
        cache->partial = sp->next;
        sp->next = cache->full;
        cache->full = sp;
        return kmalloc(size);
    }
    sp->free_head = *(void **)obj;
    sp->inuse++;
    if (sp->inuse == sp->capacity) {
        cache->partial = sp->next;
        sp->next = cache->full;
        cache->full = sp;
    }
    return obj;
}

static int free_in_list(slab_page_t **list_head, kmem_cache_t *cache, void *ptr) {
    for (slab_page_t *sp = *list_head, *prev = NULL; sp != NULL; prev = sp, sp = sp->next) {
        uintptr_t base = page2pa(sp->page) + PHYSICAL_MEMORY_OFFSET;
        uintptr_t end  = base + PGSIZE;
        if ((uintptr_t)ptr >= base && (uintptr_t)ptr < end) {
            *(void **)ptr = sp->free_head;
            sp->free_head = ptr;
            if (sp->inuse > 0) sp->inuse--;
            if (list_head == &cache->full && sp->inuse < sp->capacity) {
                if (prev) prev->next = sp->next; else *list_head = sp->next;
                sp->next = cache->partial;
                cache->partial = sp;
            }
            if (sp->inuse == 0 && sp->capacity > 0) {
                if (list_head == &cache->partial) {
                    if (prev) prev->next = sp->next; else *list_head = sp->next;
                }
                free_page(sp->page);
                free_sp(sp);
            }
            return 1;
        }
    }
    return 0;
}

void kfree(void *ptr) {
    if (ptr == NULL) return;
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
        if (free_in_list(&caches[i].partial, &caches[i], ptr)) return;
        if (free_in_list(&caches[i].full, &caches[i], ptr)) return;
    }
    large_hdr_t *hdr = (large_hdr_t *)((char *)ptr - sizeof(large_hdr_t));
    if (hdr->magic == LARGE_MAGIC && hdr->page != NULL && hdr->pages > 0) {
        free_pages(hdr->page, hdr->pages);
    }
}

void slub_check(void) {
    void *a = kmalloc(24);
    void *b = kmalloc(200);
    void *c = kmalloc(1024);
    assert(a != NULL && b != NULL && c != NULL);
    kfree(a);
    kfree(b);
    kfree(c);
}


