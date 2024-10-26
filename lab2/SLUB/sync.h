#ifndef _SYNC_H
#define _SYNC_H

#include <pthread.h>

struct mutex {
    pthread_mutex_t lock;
};

static inline void mutex_init(struct mutex *m) {
    pthread_mutex_init(&m->lock, NULL);
}

static inline void mutex_lock(struct mutex *m) {
    pthread_mutex_lock(&m->lock);
}

static inline void mutex_unlock(struct mutex *m) {
    pthread_mutex_unlock(&m->lock);
}

#endif
