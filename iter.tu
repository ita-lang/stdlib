// Foundation: Iter
// Combinadores funcionais sobre List

// === Transformation ===

pub fn chunk<T>(list: List<T>, size: Int) -> List<List<T>> {
  var result: List<List<T>> = []
  var i = 0
  while i < list.length {
    let end = if i + size < list.length { i + size } else { list.length }
    result = result + [list.slice(i, end)]
    i += size
  }
  return result
}

pub fn window<T>(list: List<T>, size: Int) -> List<List<T>> {
  var result: List<List<T>> = []
  var i = 0
  while i + size <= list.length {
    result = result + [list.slice(i, i + size)]
    i += 1
  }
  return result
}

pub fn zip<A, B>(a: List<A>, b: List<B>) -> List<(A, B)> {
  var result: List<(A, B)> = []
  let len = if a.length < b.length { a.length } else { b.length }
  var i = 0
  while i < len {
    result = result + [(a[i], b[i])]
    i += 1
  }
  return result
}

pub fn enumerate<T>(list: List<T>) -> List<(Int, T)> {
  var result: List<(Int, T)> = []
  var i = 0
  for item in list {
    result = result + [(i, item)]
    i += 1
  }
  return result
}

pub fn flatten<T>(list: List<List<T>>) -> List<T> {
  var result: List<T> = []
  for sub in list {
    result = result + sub
  }
  return result
}

pub fn flatMap<T, U>(list: List<T>, f: (T) -> List<U>) -> List<U> {
  var result: List<U> = []
  for item in list {
    result = result + f(item)
  }
  return result
}

pub fn compact<T>(list: List<Option<T>>) -> List<T> {
  var result: List<T> = []
  for item in list {
    match item {
      .some(v) => result = result + [v],
      .none => {}
    }
  }
  return result
}

pub fn intersperse<T>(list: List<T>, separator: T) -> List<T> {
  if list.length <= 1 { return list }
  var result: List<T> = [list[0]]
  var i = 1
  while i < list.length {
    result = result + [separator, list[i]]
    i += 1
  }
  return result
}

pub fn interleave<T>(a: List<T>, b: List<T>) -> List<T> {
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

pub fn takeWhile<T>(list: List<T>, predicate: (T) -> Bool) -> List<T> {
  var result: List<T> = []
  for item in list {
    if !predicate(item) { return result }
    result = result + [item]
  }
  return result
}

pub fn skipWhile<T>(list: List<T>, predicate: (T) -> Bool) -> List<T> {
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

pub fn take<T>(list: List<T>, n: Int) -> List<T> {
  if n >= list.length { return list }
  return list.slice(0, n)
}

pub fn skip<T>(list: List<T>, n: Int) -> List<T> {
  if n >= list.length { return [] }
  return list.slice(n)
}

pub fn distinct<T>(list: List<T>) -> List<T> {
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

pub fn partition<T>(list: List<T>, predicate: (T) -> Bool) -> (List<T>, List<T>) {
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

pub fn scan<T, U>(list: List<T>, initial: U, f: (U, T) -> U) -> List<U> {
  var result: List<U> = [initial]
  var acc = initial
  for item in list {
    acc = f(acc, item)
    result = result + [acc]
  }
  return result
}

pub fn groupBy<T, K>(list: List<T>, keyFn: (T) -> K) -> List<(K, List<T>)> {
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

pub fn sortBy<T>(list: List<T>, keyFn: (T) -> Int) -> List<T> {
  return quickSort(list, (a, b) => keyFn(a) - keyFn(b))
}

// === Search ===

pub fn find<T>(list: List<T>, predicate: (T) -> Bool) -> Option<T> {
  for item in list {
    if predicate(item) { return .some(item) }
  }
  return .none
}

pub fn findIndex<T>(list: List<T>, predicate: (T) -> Bool) -> Option<Int> {
  var i = 0
  for item in list {
    if predicate(item) { return .some(i) }
    i += 1
  }
  return .none
}

pub fn any<T>(list: List<T>, predicate: (T) -> Bool) -> Bool {
  for item in list {
    if predicate(item) { return true }
  }
  return false
}

pub fn all<T>(list: List<T>, predicate: (T) -> Bool) -> Bool {
  for item in list {
    if !predicate(item) { return false }
  }
  return true
}

pub fn none<T>(list: List<T>, predicate: (T) -> Bool) -> Bool {
  for item in list {
    if predicate(item) { return false }
  }
  return true
}

pub fn count<T>(list: List<T>, predicate: (T) -> Bool) -> Int {
  var c = 0
  for item in list {
    if predicate(item) { c += 1 }
  }
  return c
}

pub fn maxBy<T>(list: List<T>, keyFn: (T) -> Int) -> Option<T> {
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

pub fn minBy<T>(list: List<T>, keyFn: (T) -> Int) -> Option<T> {
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

pub fn quickSort<T>(list: List<T>, compare: (T, T) -> Int) -> List<T> {
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
