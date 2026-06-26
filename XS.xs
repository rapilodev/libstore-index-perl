#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

typedef struct {
    int cols;
    int max_rows;
    char **data; // Now storing raw C strings
} IndexedStore;

void grow_store(IndexedStore *self, int new_min_rows) {
    int old_max = self->max_rows;
    self->max_rows = ((new_min_rows / 1000) + 1) * 1000;
    self->data = (char **)realloc(self->data, self->max_rows * self->cols * sizeof(char *));
    for (int i = (old_max * self->cols); i < (self->max_rows * self->cols); i++) {
        self->data[i] = NULL;
    }
}

MODULE = Store::Indexed::XS  PACKAGE = Store::Indexed::XS

PROTOTYPES: ENABLE

SV *
_new(char *class, int cols)
    CODE:
        IndexedStore *self = (IndexedStore *)malloc(sizeof(IndexedStore));
        self->cols = cols;
        self->max_rows = 1000;
        self->data = (char **)calloc(self->max_rows * self->cols, sizeof(char *));
        SV *sv = newSV(0);
        sv_setref_pv(sv, class, (void*)self);
        RETVAL = sv;
    OUTPUT:
        RETVAL

void
_set(SV *obj, int id, int col, SV *val)
    CODE:
        IndexedStore *self = INT2PTR(IndexedStore *, SvIV(SvRV(obj)));
        if (id >= self->max_rows) grow_store(self, id);
        
        int idx = id * self->cols + col;
        if (self->data[idx]) free(self->data[idx]);
        
        // Use SvPV_nolen to safely extract string, even from numbers
        self->data[idx] = strdup(SvPV_nolen(val));
        
SV *
_get(SV *obj, int id, int col)
    CODE:
        IndexedStore *self = INT2PTR(IndexedStore *, SvIV(SvRV(obj)));
        if (id < 0 || id >= self->max_rows || !self->data[id * self->cols + col]) {
            RETVAL = &PL_sv_undef;
        } else {
            // Convert C string back to Perl SV for returning
            RETVAL = newSVpv(self->data[id * self->cols + col], 0);
        }
    OUTPUT:
        RETVAL

void
_delete(SV *obj, int id, int col)
    CODE:
        IndexedStore *self = INT2PTR(IndexedStore *, SvIV(SvRV(obj)));
        if (id >= 0 && id < self->max_rows) {
            int idx = id * self->cols + col;
            if (self->data[idx]) {
                free(self->data[idx]);
                self->data[idx] = NULL;
            }
        }

void
DESTROY(SV *obj)
    CODE:
        IndexedStore *self = INT2PTR(IndexedStore *, SvIV(SvRV(obj)));
        if (self) {
            for(int i = 0; i < self->max_rows * self->cols; i++) {
                if (self->data[i]) free(self->data[i]);
            }
            free(self->data);
            free(self);
            sv_setiv(SvRV(obj), 0);
        }