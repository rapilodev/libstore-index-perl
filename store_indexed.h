#ifndef store_indexed_h
#define store_indexed_h

#include "EXTERN.h"
#include "perl.h"
#include "uthash.h"

typedef struct {
    int id;
    char name[64];
} StoreKey;

typedef struct {
    StoreKey key;
    SV *value;
    UT_hash_handle hh;
} StoreEntry;

typedef struct {
    StoreEntry *map;
} store_indexed;

void store_indexed_init(store_indexed *store);
void store_indexed_set(pTHX_ store_indexed *store, int id, const char *name, SV *value);
SV* store_indexed_get(pTHX_ store_indexed *store, int id, const char *name);
void store_indexed_free(pTHX_ store_indexed *store);

#endif
