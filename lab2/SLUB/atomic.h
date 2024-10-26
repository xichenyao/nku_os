#ifndef _ATOMIC_H
#define _ATOMIC_H

typedef struct { int counter; } atomic_int;

#define atomic_set(ptr, v) ((ptr)->counter = v)
#define atomic_read(ptr) ((ptr)->counter)
#define atomic_inc(ptr) (__sync_add_and_fetch(&(ptr)->counter, 1))
#define atomic_dec(ptr) (__sync_sub_and_fetch(&(ptr)->counter, 1))

#endif
