# Store::Indexed

`Store::Indexed` is a key-indexed data store for Perl, offering a seamless interface for storing and retrieving values indexed by an integer ID and a string name. It features a dual-backend architecture: a high-speed C-based XS backend and a portable Pure-Perl fallback.

## Architecture & Design

The module uses a factory pattern to determine the optimal backend at runtime.

## Installation

### Prerequisites

* Perl 5.10 or higher
* A C compiler (for the XS backend)
* `uthash` (header provided)

### Build Instructions

```bash
perl Makefile.PL
make
make test
make install

```

## Usage

### Basic Usage

The module defaults to `XS` if available, falling back to `PP` automatically.

```perl
use Store::Indexed;

my $store = Store::Indexed->new();
$store->set(1, "config_key", "value");
my $val = $store->get(1, "config_key");

```

### Forcing a Backend

You can force a specific backend via import tags or environment variables:

```perl
# Via import tags
use Store::Indexed ':xs';

# Via environment variable
$ENV{STORE_BACKEND} = 'PP';

```

## Backends

| Backend | Implementation | Use Case |
| --- | --- | --- |
| **XS** | C / `uthash` | High-performance, production environments. |
| **PP** | Pure Perl | Portability, restricted environments, testing. |

## Memory Management

The XS backend utilizes Perl's reference counting (`SvREFCNT`) to ensure that scalars stored in the underlying C hash are garbage collected correctly when removed or when the store is destroyed.

