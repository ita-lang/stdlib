// Foundation: Async
// Patterns de concorrência compostos sobre async/await nativo

// === Retry ===
async fn retry<T>(times: Int, delayMs: Int, fn: () -> Result<T, String>) -> Result<T, String> {
  var attempt = 0
  var lastError:String = ""
  while attempt < times {
    match fn() {
      .ok(value) => return .ok(value),
      .err(e) => {
        lastError = e
        attempt += 1
        if attempt < times {
          await Timer.delay(delayMs)
        }
      }
    }
  }
  return .err("Failed after ${times} attempts: ${lastError}")
}

async fn retryWithBackoff<T>(times: Int, baseDelayMs: Int, fn: () -> Result<T, String>) -> Result<T, String> {
  var attempt = 0
  var lastError = ""
  var delay = baseDelayMs
  while attempt < times {
    match fn() {
      .ok(value) => return .ok(value),
      .err(e) => {
        lastError = e
        attempt += 1
        if attempt < times {
          await Timer.delay(delay)
          delay = delay * 2  // Exponential backoff
        }
      }
    }
  }
  return .err("Failed after ${times} attempts: ${lastError}")
}

// === Timeout ===

async fn timeout<T>(ms: Int, fn: async () -> T) -> Result<T, String> {
  // Race between the function and a timer
  let result = await race(
  async () => .ok(await fn()),
  async () => {
    await Timer.delay(ms)
    return .err("Timeout after ${ms}ms")
  }
  )
  return result
}

// === Debounce & Throttle ===

struct Debouncer<T> {
  delayMs: Int
  lastCall: Int
  pending: Option<T>

  fn new(delayMs: Int) -> Debouncer<T> {
    return Debouncer { delayMs: delayMs, lastCall: 0, pending: .none }
  }

  fn call(self, value: T, now: Int) -> (Bool, Debouncer<T>) {
    let elapsed = now - self.lastCall
    if elapsed >= self.delayMs {
      return (true, Debouncer { delayMs: self.delayMs, lastCall: now, pending: .none })
    }
    return (false, Debouncer { delayMs: self.delayMs, lastCall: self.lastCall, pending: .some(value) })
  }
}

struct Throttler {
  intervalMs: Int
  lastCall: Int

  fn new(intervalMs: Int) -> Throttler {
    return Throttler { intervalMs: intervalMs, lastCall: 0 }
  }

  fn canCall(self, now: Int) -> (Bool, Throttler) {
    let elapsed = now - self.lastCall
    if elapsed >= self.intervalMs {
      return (true, Throttler { intervalMs: self.intervalMs, lastCall: now })
    }
    return (false, self)
  }
}

// === Semaphore ===

struct Semaphore {
  maxConcurrent: Int
  current: Int

  fn new(max: Int) -> Semaphore {
    return Semaphore { maxConcurrent: max, current: 0 }
  }

  fn acquire(self) -> Option<Semaphore> {
    if self.current >= self.maxConcurrent { return .none }
    return .some(Semaphore { maxConcurrent: self.maxConcurrent, current: self.current + 1 })
  }

  fn release(self) -> Semaphore {
    let newCurrent = if self.current > 0 { self.current - 1 } else { 0 }
    return Semaphore { maxConcurrent: self.maxConcurrent, current: newCurrent }
  }

  fn available(self) -> Int => self.maxConcurrent - self.current
  fn isFull(self) -> Bool => self.current >= self.maxConcurrent
}

// === RateLimiter ===

struct RateLimiter {
  maxRequests: Int
  windowMs: Int
  timestamps: List<Int>

  fn new(maxRequests: Int, windowMs: Int) -> RateLimiter {
    return RateLimiter { maxRequests: maxRequests, windowMs: windowMs, timestamps: [] }
  }

  fn check(self, now: Int) -> (Bool, RateLimiter) {
    // Remove expired timestamps
    var valid: List<Int> = []
    for ts in self.timestamps {
      if now - ts < self.windowMs {
        valid = valid + [ts]
      }
    }
    if valid.length >= self.maxRequests {
      return (false, RateLimiter { maxRequests: self.maxRequests, windowMs: self.windowMs, timestamps: valid })
    }
    return (true, RateLimiter {
      maxRequests: self.maxRequests,
      windowMs: self.windowMs,
      timestamps: valid + [now]
    })
  }

  fn remaining(self, now: Int) -> Int {
    var count = 0
    for ts in self.timestamps {
      if now - ts < self.windowMs { count += 1 }
    }
    return self.maxRequests - count
  }

  fn resetAt(self, now: Int) -> Int {
    if self.timestamps.length == 0 { return now }
    return self.timestamps[0] + self.windowMs
  }
}

// === Pool ===

struct Pool<T> {
  available: List<T>
  maxSize: Int

  fn new(items: List<T>) -> Pool<T> {
    return Pool { available: items, maxSize: items.length }
  }

  fn acquire(self) -> Option<(T, Pool<T>)> {
    if self.available.length == 0 { return .none }
    let item = self.available[0]
    let rest = self.available.slice(1)
    return .some((item, Pool { available: rest, maxSize: self.maxSize }))
  }

  fn release(self, item: T) -> Pool<T> {
    if self.available.length >= self.maxSize { return self }
    return Pool { available: self.available + [item], maxSize: self.maxSize }
  }

  fn size(self) -> Int => self.available.length
  fn isEmpty(self) -> Bool => self.available.length == 0
}
