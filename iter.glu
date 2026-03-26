// Foundation: Iter
// Combinadores funcionais sobre List

// === Transformation ===

fn chunk<T>(list: List<T>, size: Int) -> List<List<T>> {
  var result: List<List<T>> = []
  var i = 0
  while i < list.length {
    let end = if i + size < list.length { i + size } else { list.length }
    result = result + [list.slice(i, end)]
    i += size
  }
  return result
}

fn window<T>(list: List<T>, size: Int) -> List<List<T>> {
  var result: List<List<T>> = []
  var i = 0
  while i + size <= list.length {
    result = result + [list.slice(i, i + size)]
    i += 1
  }
  return result
}

fn zip<A, B>(a: List<A>, b: List<B>) -> List<(A, B)> {
  var result: List<(A, B)> = []
  let len = if a.length < b.length { a.length } else { b.length }
  var i = 0
  while i < len {
    result = result + [(a[i], b[i])]
    i += 1
  }
  return result
}

fn enumerate<T>(list: List<T>) -> List<(Int, T)> {
  var result: List<(Int, T)> = []
  var i = 0
  for item in list {
    result = result + [(i, item)]
    i += 1
  }
  return result
}

fn flatten<T>(list: List<List<T>>) -> List<T> {
  var result: List<T> = []
  for sub in list {
    result = result + sub
  }
  return result
}

fn flatMap<T, U>(list: List<T>, fn: (T) -> List<U>) -> List<U> {
  var result: List<U> = []
  for item in list {
    result = result + fn(item)
  }
  return result
}

fn compact<T>(list: List<Option<T>>) -> List<T> {
  var result: List<T> = []
  for item in list {
    match item {
      .some(v) => result = result + [v],
      .none => {}
    }
  }
  return result
}

fn intersperse<T>(list: List<T>, separator: T) -> List<T> {
  if list.length <= 1 { return list }
  var result: List<T> = [list[0]]
  var i = 1
  while i < list.length {
    result = result + [separator, list[i]]
    i += 1
  }
  return result
}

fn interleave<T>(a: List<T>, b: List<T>) -> List<T> {
  var result: List<T> = []
  let len = if a.length > b.length { a.length } else { b.length }
  var i = 0
  while i < len {
    if i < a.length { result = result + [a[i]] }
    if i < b.length { result = result + [b[i]] }
    i += 1
  }
  return result
}

// === Filtering ===

fn takeWhile<T>(list: List<T>, predicate: (T) -> Bool) -> List<T> {
  var result: List<T> = []
  for item in list {
    if !predicate(item) { return result }
    result = result + [item]
  }
  return result
}

fn skipWhile<T>(list: List<T>, predicate: (T) -> Bool) -> List<T> {
  var skipping = true
  var result: List<T> = []
  for item in list {
    if skipping && predicate(item) { } else {
      skipping = false
      result = result + [item]
    }
  }
  return result
}

fn take<T>(list: List<T>, n: Int) -> List<T> {
  if n >= list.length { return list }
  return list.slice(0, n)
}

fn skip<T>(list: List<T>, n: Int) -> List<T> {
  if n >= list.length { return [] }
  return list.slice(n)
}

fn distinct<T>(list: List<T>) -> List<T> {
  var result: List<T> = []
  for item in list {
    var found = false
    for existing in result {
      if existing == item { found = true }
    }
    if !found { result = result + [item] }
  }
  return result
}

fn partition<T>(list: List<T>, predicate: (T) -> Bool) -> (List<T>, List<T>) {
  var yes: List<T> = []
  var no: List<T> = []
  for item in list {
    if predicate(item) {
      yes = yes + [item]
    } else {
      no = no + [item]
    }
  }
  return (yes, no)
}

// === Aggregation ===

fn scan<T, U>(list: List<T>, initial: U, fn: (U, T) -> U) -> List<U> {
  var result: List<U> = [initial]
  var acc = initial
  for item in list {
    acc = fn(acc, item)
    result = result + [acc]
  }
  return result
}

fn groupBy<T, K>(list: List<T>, keyFn: (T) -> K) -> List<(K, List<T>)> {
  var keys: List<K> = []
  var groups: List<List<T>> = []
  for item in list {
    let key = keyFn(item)
    var found = false
    var i = 0
    while i < keys.length {
      if keys[i] == key {
        groups = groups.set(i, groups[i] + [item])
        found = true
        i = keys.length // break
      }
      i += 1
    }
    if !found {
      keys = keys + [key]
      groups = groups + [[item]]
    }
  }
  var result: List<(K, List<T>)> = []
  var i = 0
  while i < keys.length {
    result = result + [(keys[i], groups[i])]
    i += 1
  }
  return result
}

fn sortBy<T>(list: List<T>, keyFn: (T) -> Int) -> List<T> {
  return quickSort(list, (a, b) => keyFn(a) - keyFn(b))
}

// === Search ===

fn find<T>(list: List<T>, predicate: (T) -> Bool) -> Option<T> {
  for item in list {
    if predicate(item) { return .some(item) }
  }
  return .none
}

fn findIndex<T>(list: List<T>, predicate: (T) -> Bool) -> Option<Int> {
  var i = 0
  for item in list {
    if predicate(item) { return .some(i) }
    i += 1
  }
  return .none
}

fn any<T>(list: List<T>, predicate: (T) -> Bool) -> Bool {
  for item in list {
    if predicate(item) { return true }
  }
  return false
}

fn all<T>(list: List<T>, predicate: (T) -> Bool) -> Bool {
  for item in list {
    if !predicate(item) { return false }
  }
  return true
}

fn none<T>(list: List<T>, predicate: (T) -> Bool) -> Bool {
  for item in list {
    if predicate(item) { return false }
  }
  return true
}

fn count<T>(list: List<T>, predicate: (T) -> Bool) -> Int {
  var c = 0
  for item in list {
    if predicate(item) { c += 1 }
  }
  return c
}

fn maxBy<T>(list: List<T>, keyFn: (T) -> Int) -> Option<T> {
  if list.length == 0 { return .none }
  var best = list[0]
  var bestKey = keyFn(best)
  var i = 1
  while i < list.length {
    let k = keyFn(list[i])
    if k > bestKey {
      best = list[i]
      bestKey = k
    }
    i += 1
  }
  return .some(best)
}

fn minBy<T>(list: List<T>, keyFn: (T) -> Int) -> Option<T> {
  if list.length == 0 { return .none }
  var best = list[0]
  var bestKey = keyFn(best)
  var i = 1
  while i < list.length {
    let k = keyFn(list[i])
    if k < bestKey {
      best = list[i]
      bestKey = k
    }
    i += 1
  }
  return .some(best)
}

// === Helpers (imported from collections for sortBy) ===

fn quickSort<T>(list: List<T>, compare: (T, T) -> Int) -> List<T> {
  if list.length <= 1 { return list }
  let pivot = list[list.length / 2]
  var less: List<T> = []
  var equal: List<T> = []
  var greater: List<T> = []
  for item in list {
    let cmp = compare(item, pivot)
    if cmp < 0 { less = less + [item] }
    else if cmp == 0 { equal = equal + [item] }
    else { greater = greater + [item] }
  }
  return quickSort(less, compare) + equal + quickSort(greater, compare)
}
