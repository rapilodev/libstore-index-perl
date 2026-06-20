#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "store_indexed.h"

MODULE = Store::Indexed::XS     PACKAGE = Store::Indexed::XS

store_indexed *
new(class)
    char *class
    CODE:
        RETVAL = malloc(sizeof(store_indexed));
        store_indexed_init(RETVAL);
    OUTPUT:
        RETVAL

void
set(self, id, name, value)
    store_indexed *self
    int id
    char *name
    SV *value
    CODE:
        store_indexed_set(aTHX_ self, id, name, value);

SV *
get(self, id, name)
    store_indexed *self
    int id
    char *name
    CODE:
        RETVAL = store_indexed_get(aTHX_ self, id, name);
    OUTPUT:
        RETVAL

void
DESTROY(self)
    store_indexed *self
    CODE:
        if (self) {
            store_indexed_free(aTHX_ self);
            free(self);
        }
