#define KHASHL_MAP_IMPLEMENTATION
#include "store_indexed.h"

void store_indexed_init(store_indexed *store) {
    store->map = kh_store_init();
}

void store_indexed_set(pTHX_ store_indexed *store, int id, const char *name, SV *value) {
    StoreKey lookup_k;
    lookup_k.id = id;
    lookup_k.name = (char*)name;

    int absent;
    khint_t i = kh_store_put(store->map, lookup_k, &absent);

    if (!absent) {
        if (kh_val(store->map, i)) {
            free(kh_val(store->map, i));
        }
    } else {
        kh_key(store->map, i).name = strdup(name);
    }
    if (value && SvOK(value)) {
        kh_val(store->map, i) = strdup(SvPV_nolen(value));
    } else {
        kh_val(store->map, i) = NULL;
    }
}

SV* store_indexed_get(pTHX_ store_indexed *store, int id, const char *name) {
    StoreKey lookup_k;
    lookup_k.id = id;
    lookup_k.name = (char*)name;

    khint_t i = kh_store_get(store->map, lookup_k);

    if (i != kh_end(store->map)) {
        char *stored_val = kh_val(store->map, i);
        if (stored_val) {
            return newSVpv(stored_val, 0); // Return a new, independent SV
        }
    }
    return newSV(0);
}

void store_indexed_free(pTHX_ store_indexed *store) {
    if (!store || !store->map) return;

    for (khint_t i = 0; i < kh_end(store->map); ++i) {
        if (kh_exist(store->map, i)) {
            free(kh_key(store->map, i).name);

            // Only free the value if it isn't NULL (undef)
            if (kh_val(store->map, i)) {
                free(kh_val(store->map, i));
            }
        }
    }

    kh_store_destroy(store->map);
}
