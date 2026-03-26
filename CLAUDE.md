# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with the Itá standard library.

## O que é

Standard library da linguagem Itá, escrita inteiramente em pure `.glu`. Fornece abstrações de alto nível sobre os ~35 namespaces built-in do codegen.

## Módulos (12)

| Módulo | Arquivo | Destaques |
|--------|---------|-----------|
| math | `math.glu` | pi, e, abs, clamp, lerp, gcd, lcm, isPrime, fibonacci, pow, range |
| text | `text.glu` | camelCase, snakeCase, slugify, trim, pad, isEmail, isUrl, template |
| collections | `collections.glu` | Stack, Queue, Deque, PriorityQueue, Ring, OrderedMap, OrderedSet, Graph, DiGraph, WeightedGraph (Dijkstra, BFS, DFS, topologicalSort, MST), mergeSort, quickSort, heapSort, insertionSort, timSort, radixSort |
| iter | `iter.glu` | chunk, window, zip, enumerate, flatten, flatMap, compact, groupBy, partition, scan, distinct, takeWhile, skipWhile, sortBy |
| log | `log.glu` | Logger struct com níveis (debug/info/warn/error/fatal), cores ANSI, contexto |
| cache | `cache.glu` | Cache LRU com TTL, getOrSet, prune |
| datetime | `datetime.glu` | format, relative, add/subtract, diff, startOf/endOf, dayOfWeek, isLeapYear |
| event | `event.glu` | Emitter\<T\> (on/off/once/emit), EventBus multi-channel |
| validate | `validate.glu` | Schema builder (.string().min(3).email()), ObjectSchema, → Result |
| async | `async.glu` | retry, retryWithBackoff, timeout, Debouncer, Throttler, Semaphore, RateLimiter, Pool |
| config | `config.glu` | Config.load (TOML), env overrides, merge, type-safe getters |
| server | `server.glu` | App, Router, Route, middleware chain (Result-based), CORS, auth, rate limiting, route params |

## Princípios

- **Pure .glu** — nenhum código Dart, tudo na linguagem
- Usa primitivas nativas como base (Map, List, File, Toml, Env, Http, etc.)
- Structs imutáveis com copy-with para estado
- Sem classes — apenas structs e funções
- Sem annotations, sem mágica

## Uso

```
import { mergeSort, Graph } from "collections"
import { camelCase, slugify } from "text"
import { sum, isPrime } from "math"
import { Logger } from "log"
```

## Organização

Parte da org [ita-lang](https://github.com/ita-lang). Compilador em [ita](https://github.com/ita-lang/ita).
