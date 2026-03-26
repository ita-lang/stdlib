// Foundation: Cache
// Cache LRU em memória com TTL opcional

struct CacheEntry<V> {
  value: V
  createdAt: Int
  lastAccess: Int
}

struct Cache<K, V> {
  entries: List<(K, CacheEntry<V>)>
  maxSize: Int
  ttlMs: Int  // 0 = sem TTL

  fn new(maxSize: Int) -> Cache<K, V> {
    return Cache { entries: [], maxSize: maxSize, ttlMs: 0 }
  }

  fn withTtl(maxSize: Int, ttlMs: Int) -> Cache<K, V> {
    return Cache { entries: [], maxSize: maxSize, ttlMs: ttlMs }
  }

  fn get(self, key: K, now: Int) -> Option<V> {
    var i = 0
    while i < self.entries.length {
      let {k, entry} = self.entries[i]
      if k == key {
        if self.ttlMs > 0 && (now - entry.createdAt) > self.ttlMs {
          return .none
        }
        return .some(entry.value)
      }
      i += 1
    }
    return .none
  }

  fn set(self, key: K, value: V, now: Int) -> Cache<K, V> {
    let entry = CacheEntry { value: value, createdAt: now, lastAccess: now }

    // Update existing
    var i = 0
    while i < self.entries.length {
      let {k, _} = self.entries[i]
      if k == key {
        return Cache {
          entries: self.entries.set(i, (key, entry)),
          maxSize: self.maxSize,
          ttlMs: self.ttlMs
        }
      }
      i += 1
    }

    // Evict LRU if full
    var entries = self.entries
    if entries.length >= self.maxSize {
      var oldestIdx = 0
      var oldestAccess = entries[0].1.lastAccess
      i = 1
      while i < entries.length {
        if entries[i].1.lastAccess < oldestAccess {
          oldestIdx = i
          oldestAccess = entries[i].1.lastAccess
        }
        i += 1
      }
      // Remove oldest
      var newEntries: List<(K, CacheEntry<V>)> = []
      i = 0
      while i < entries.length {
        if i != oldestIdx { newEntries = newEntries + [entries[i]] }
        i += 1
      }
      entries = newEntries
    }

    return Cache {
      entries: entries + [(key, entry)],
      maxSize: self.maxSize,
      ttlMs: self.ttlMs
    }
  }

  fn has(self, key: K, now: Int) -> Bool {
    match self.get(key, now) {
      .some(_) => true,
      .none => false
    }
  }

  fn delete(self, key: K) -> Cache<K, V> {
    var newEntries: List<(K, CacheEntry<V>)> = []
    for entry in self.entries {
      let {k, _} = entry
      if k != key { newEntries = newEntries + [entry] }
    }
    return Cache { entries: newEntries, maxSize: self.maxSize, ttlMs: self.ttlMs }
  }

  fn clear(self) -> Cache<K, V> {
    return Cache { entries: [], maxSize: self.maxSize, ttlMs: self.ttlMs }
  }

  fn size(self) -> Int => self.entries.length

  fn getOrSet(self, key: K, now: Int, compute: () -> V) -> (V, Cache<K, V>) {
    match self.get(key, now) {
      .some(v) => (v, self),
      .none => {
        let value = compute()
        let updated = self.set(key, value, now)
        (value, updated)
      }
    }
  }

  // Remove expired entries
  fn prune(self, now: Int) -> Cache<K, V> {
    if self.ttlMs == 0 { return self }
    var newEntries: List<(K, CacheEntry<V>)> = []
    for entry in self.entries {
      let {_, e} = entry
      if (now - e.createdAt) <= self.ttlMs {
        newEntries = newEntries + [entry]
      }
    }
    return Cache { entries: newEntries, maxSize: self.maxSize, ttlMs: self.ttlMs }
  }
}
