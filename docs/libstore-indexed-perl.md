# Store::Indexed(3)

## NAME

**Store::Indexed** - A fast, key-indexed data store with dual XS and Pure-Perl backends.

## SYNOPSIS

```perl
use Store::Indexed;

# Auto-detects best backend (XS preferred)
my $store = Store::Indexed->new();

# Or force a specific backend
use Store::Indexed ':xs';
my $store = Store::Indexed->new(backend => 'XS');

$store->set(1, "my_key", "data");
my $val = $store->get(1, "my_key");

```

## DESCRIPTION

**Store::Indexed** provides an interface for storing and retrieving data points indexed by an integer ID and a string name. It supports both a highly optimized C-based implementation (`XS`) and a portable `Pure-Perl` implementation (`PP`).

## IMPORT TAGS

* `:xs` - Forces the use of the `Store::Indexed::XS` backend.
* `:pp` - Forces the use of the `Store::Indexed::PP` backend.

## METHODS

### new(%args)

Creates a new `Store::Indexed` instance.

* `backend`: Can be set to `'XS'` or `'PP'` to override environment or import settings.

### set($id, $name, $value)

Associates a scalar `$value` with a composite key of `$id` and `$name`.

### get($id, $name)

Returns the scalar value associated with the specified `$id` and `$name`, or `undef` if not found.

---

# Store::Indexed::XS(3)

## DESCRIPTION

The `XS` backend provides a memory-efficient implementation utilizing `uthash` for O(1) average-time complexity lookups. This module is intended for production environments where performance is critical.

## REQUIREMENTS

* A C compiler (e.g., `gcc`, `clang`)
* `khashl.h` library (included in source)
* Perl 5.10+

---

# Store::Indexed::PP(3)

## DESCRIPTION

The `PP` (Pure-Perl) backend provides a fallback implementation for environments where compiling C extensions is not possible (e.g., restricted hosting, cross-compilation targets).

## NOTES

While functionally equivalent to the `XS` backend, the `PP` version maintains data in a standard Perl hash, which may consume more memory for large datasets compared to the `XS` implementation.

---

## ENVIRONMENT

* `STORE_BACKEND`: Set to `XS` or `PP` to globally define the preferred backend for the current process.


## SEE ALSO

`XSLoader`, `perlxs`, `perlobject`

