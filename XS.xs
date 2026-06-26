#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

// Set a safe maximum or implement a growing array if needed
#define MAX_ROWS 1100000 

typedef struct {
    int cols;
    SV **data;
} IndexedStore;

MODULE = Store::Indexed::XS  PACKAGE = Store::Indexed::XS

PROTOTYPES: ENABLE

SV *
_new(char *class, int cols)
    CODE:
        IndexedStore *self = (IndexedStore *)malloc(sizeof(IndexedStore));
        self->cols = cols;
        // Allocate memory for 1.1 million rows
        self->data = (SV **)calloc(MAX_ROWS * cols, sizeof(SV *));
        
        SV *sv = newSV(0);
        sv_setref_pv(sv, class, (void*)self);
        RETVAL = sv;
    OUTPUT:
        RETVAL

void
_set(SV *obj, int id, int col, SV *val)
    CODE:
        IndexedStore *self = INT2PTR(IndexedStore *, SvIV(SvRV(obj)));
        if (id < 0 || id >= MAX_ROWS) croak("ID %d out of bounds", id);
        
        int idx = id * self->cols + col;
        if (self->data[idx]) SvREFCNT_dec(self->data[idx]);
        self->data[idx] = newSVsv(val);

SV *
_get(SV *obj, int id, int col)
    CODE:
        IndexedStore *self = INT2PTR(IndexedStore *, SvIV(SvRV(obj)));
        if (id < 0 || id >= MAX_ROWS) croak("ID %d out of bounds", id);
        
        int idx = id * self->cols + col;
        if (self->data[idx]) {
            RETVAL = SvREFCNT_inc(self->data[idx]);
        } else {
            // Return undef if index is empty
            RETVAL = &PL_sv_undef;
        }
    OUTPUT:
        RETVAL

bool
_exists(SV *obj, int id, int col)
    CODE:
        IndexedStore *self = INT2PTR(IndexedStore *, SvIV(SvRV(obj)));
        if (id < 0 || id >= MAX_ROWS) {
            RETVAL = 0;
        } else {
            int idx = id * self->cols + col;
            RETVAL = (self->data[idx] != NULL);
        }
    OUTPUT:
        RETVAL
        
void
DESTROY(SV *obj)
    CODE:
        IndexedStore *self = INT2PTR(IndexedStore *, SvIV(SvRV(obj)));
        if (self) {
            for(int i = 0; i < MAX_ROWS * self->cols; i++) {
                if (self->data[i]) SvREFCNT_dec(self->data[i]);
            }
            free(self->data);
            free(self);
            sv_setiv(SvRV(obj), 0);
        }