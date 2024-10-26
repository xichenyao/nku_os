#ifndef _ASSERT_H
#define _ASSERT_H

#include <stdio.h>
#include <stdlib.h>

#define assert(expr) do {                   \
    if (!(expr)) {                          \
        printf("Assertion failed: %s\n", #expr); \
        exit(1);                            \
    }                                       \
} while (0)

#endif
