# Itá Standard Library

The standard library for the [Itá programming language](https://github.com/ita-lang/ita), written entirely in pure `.ita`.

## Modules

| Module | Description |
|--------|-------------|
| `math` | Constants, arithmetic, number theory, sequences |
| `text` | Case conversion, padding, validation, slugify, template |
| `collections` | Stack, Queue, Deque, PriorityQueue, Ring, OrderedMap, OrderedSet, Graph, DiGraph, WeightedGraph, 6 sorting algorithms |
| `iter` | Functional combinators: chunk, window, zip, groupBy, partition, scan, distinct |
| `log` | Structured logging with levels, colors, context |
| `cache` | LRU cache with TTL, getOrSet, prune |
| `datetime` | Format, relative time, add/subtract, diff, boundaries |
| `event` | Emitter\<T\> (on/off/once/emit), EventBus |
| `validate` | Schema builder → Result validation |
| `async` | Retry, backoff, Semaphore, RateLimiter, Pool |
| `config` | TOML + env merge, type-safe getters |
| `server` | Express-style HTTP framework |

## Usage

```
import { mergeSort, Stack, Graph } from "collections"
import { camelCase, slugify } from "text"
import { sum, isPrime, fibonacci } from "math"
```

## License

MIT
