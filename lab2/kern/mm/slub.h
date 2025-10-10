#ifndef __KERN_MM_SLUB_H__
#define __KERN_MM_SLUB_H__

#include <defs.h>

/*
 * Function: SLUB interface
 * -----------------------
 * - slub_init(): initialize caches and internal lists
 * - kmalloc(size): allocate size bytes, returns valid kernel virtual pointer or NULL
 * - kfree(ptr): free a pointer allocated by kmalloc
 * - slub_check(): run internal tests to validate correctness
 */

void slub_init(void);
void *kmalloc(size_t size);
void kfree(void *ptr);
void slub_check(void);

#endif /* !__KERN_MM_SLUB_H__ */


