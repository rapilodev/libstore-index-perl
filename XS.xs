#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

typedef struct {
    int cols;
    int max_rows;    // Current capacity
    SV **data;
} IndexedStore;

/* Helper to grow the storage */
void grow_store(IndexedStore *self, int new_min_rows) {
    int old_max = self->max_rows;
    // Calculate new capacity: round up to nearest 1000
    self->max_rows = ((new_min_rows / 1000) + 1) * 1000;
    
    // Reallocate the data array
    self->data = (SV **)realloc(self->data, self->max_rows * self->cols * sizeof(SV *));
    
    // Initialize the new memory slots to NULL
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
        self->max_rows = 1000; // Start with 1000
        self->data = (SV **)calloc(self->max_rows * self->cols, sizeof(SV *));
        
        SV *sv = newSV(0);
        sv_setref_pv(sv, class, (void*)self);
        RETVAL = sv;
    OUTPUT:
        RETVAL

void
_set(SV *obj, int id, int col, SV *val)
    CODE:
        IndexedStore *self = INT2PTR(IndexedStore *, SvIV(SvRV(obj)));
        if (id < 0) croak("ID must be positive");
        
        // Grow if ID exceeds current capacity
        if (id >= self->max_rows) {
            grow_store(self, id);
        }
        
        int idx = id * self->cols + col;
        if (self->data[idx]) SvREFCNT_dec(self->data[idx]);
        self->data[idx] = newSVsv(val);

SV *
_get(SV *obj, int id, int col)
    CODE:
        IndexedStore *self = INT2PTR(IndexedStore *, SvIV(SvRV(obj)));
        if (id < 0 || id >= self->max_rows) {
            RETVAL = &PL_sv_undef;
        } else {
            int idx = id * self->cols + col;
            if (self->data[idx]) {
                RETVAL = SvREFCNT_inc(self->data[idx]);
            } else {
                RETVAL = &PL_sv_undef;
            }
        }
    OUTPUT:
        RETVAL

bool
_exists(SV *obj, int id, int col)
    CODE:
        IndexedStore *self = INT2PTR(IndexedStore *, SvIV(SvRV(obj)));
        if (id < 0 || id >= self->max_rows) {
            RETVAL = 0;
        } else {
            int idx = id * self->cols + col;
            RETVAL = (self->data[idx] != NULL);
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
                SvREFCNT_dec(self->data[idx]);
                self->data[idx] = NULL;
            }
        }

void
DESTROY(SV *obj)
    CODE:
        IndexedStore *self = INT2PTR(IndexedStore *, SvIV(SvRV(obj)));
        if (self) {
            for(int i = 0; i < self->max_rows * self->cols; i++) {
                if (self->data[i]) SvREFCNT_dec(self->data[i]);
            }
            free(self->data);
            free(self);
            sv_setiv(SvRV(obj), 0);
        }