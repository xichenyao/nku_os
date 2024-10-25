#ifndef _DEFS_H
#define _DEFS_H

#include <stddef.h>
#include <stdint.h>

#define GFP_KERNEL 0 // 标识内核内存分配

void *kmalloc(size_t size, int flags); // 内存分配
void kfree(void *ptr); // 释放内存
struct page *alloc_pages(int order); // 页分配

#endif
