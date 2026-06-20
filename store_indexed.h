#ifndef STORE_INDEXED_H
#define STORE_INDEXED_H

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <string.h>
#include <stdlib.h>

#ifndef KH_INLINE
#define KH_INLINE static inline
#endif

#include "khashl.h"

typedef struct {
    int id;
    char *name;
} StoreKey;

static inline khint_t hash_func(StoreKey k) {
    khint_t h = (khint_t)k.id;
    const char *s = k.name;
    if (s) {
        while (*s) h = (h << 5) - h + (khint_t)*s++;
    }
    return h;
}

static inline int eq_func(StoreKey a, StoreKey b) {
    if (a.id != b.id) return 0;
    if (!a.name || !b.name) return a.name == b.name;
    return strcmp(a.name, b.name) == 0;
}

KHASHL_MAP_INIT(KH_INLINE, kh_store_t, kh_store, StoreKey, char*, hash_func, eq_func)

typedef struct {
    kh_store_t *map;
} store_indexed;

void store_indexed_init(store_indexed *store);
void store_indexed_set(pTHX_ store_indexed *store, int id, const char *name, SV *value);
SV* store_indexed_get(pTHX_ store_indexed *store, int id, const char *name);
void store_indexed_free(pTHX_ store_indexed *store);

#endif
