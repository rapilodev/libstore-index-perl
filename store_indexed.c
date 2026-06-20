#include "store_indexed.h"

void store_indexed_init(store_indexed *store) {
    store->map = NULL;
}

void store_indexed_set(pTHX_ store_indexed *store, int id, const char *name, SV *value) {
    StoreEntry *entry;
    StoreKey lookup_key;
    memset(&lookup_key, 0, sizeof(StoreKey));
    lookup_key.id = id;
    strncpy(lookup_key.name, name, sizeof(lookup_key.name) - 1);

    HASH_FIND(hh, store->map, &lookup_key, sizeof(StoreKey), entry);

    if (entry) {
        SV *old_value = entry->value;
        entry->value = SvREFCNT_inc(value);
        SvREFCNT_dec(old_value);
    } else {
        entry = malloc(sizeof(StoreEntry));
        entry->key = lookup_key;
        entry->value = SvREFCNT_inc(value);
        HASH_ADD(hh, store->map, key, sizeof(StoreKey), entry);
    }
}

SV* store_indexed_get(pTHX_ store_indexed *store, int id, const char *name) {
    StoreEntry *entry;

    StoreKey lookup_key;
    memset(&lookup_key, 0, sizeof(StoreKey));
    lookup_key.id = id;
    strncpy(lookup_key.name, name, sizeof(lookup_key.name) - 1);

    HASH_FIND(hh, store->map, &lookup_key, sizeof(StoreKey), entry);

    if (entry) {
        return newSVsv(entry->value);
    }

    return &PL_sv_undef;
}
void store_indexed_free(pTHX_ store_indexed *store) {
    StoreEntry *current, *tmp;
    HASH_ITER(hh, store->map, current, tmp) {
        HASH_DEL(store->map, current);
        SvREFCNT_dec(current->value);
        free(current);
    }
}
