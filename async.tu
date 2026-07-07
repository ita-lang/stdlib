// Foundation: Async
// Patterns de concorrência compostos sobre async/await nativo

// === Retry ===

// NOTA de dialeto: o param originalmente chamado `fn` foi renomeado para `task`
// (`fn` é keyword). O `match` imperativo com `return`/bloco no braço não é aceito,
// então o resultado é inspecionado com braços-expressão (`.ok(_) => true`, ...).
async fn retry<T>(times: Int, delayMs: Int, task: () -> Result<T, String>) -> Result<T, String> {
  var attempt = 0
  var lastError = ""
  while attempt < times {
    let r = task()
    let ok = match r {
      .ok(_) => true,
      .err(_) => false
    }
    if ok {
      return r
    }
    lastError = match r {
      .ok(_) => lastError,
      .err(e) => e
    }
    attempt += 1
    if attempt < times {
      await Timer.delay(delayMs)
    }
  }
  return .err("Failed after ${times} attempts: ${lastError}")
}

async fn retryWithBackoff<T>(times: Int, baseDelayMs: Int, task: () -> Result<T, String>) -> Result<T, String> {
  var attempt = 0
  var lastError = ""
  var delay = baseDelayMs
  while attempt < times {
    let r = task()
    let ok = match r {
      .ok(_) => true,
      .err(_) => false
    }
    if ok {
      return r
    }
    lastError = match r {
      .ok(_) => lastError,
      .err(e) => e
    }
    attempt += 1
    if attempt < times {
      await Timer.delay(delay)
      delay = delay * 2  // Exponential backoff
    }
  }
  return .err("Failed after ${times} attempts: ${lastError}")
}

// === Timeout ===

// `task` é uma closure async (`async () -> T`). Cada braço da corrida é uma
// closure async INVOCADA — `race`/`Future.any` corre sobre os Futures resultantes.
async fn timeout<T>(ms: Int, task: async () -> T) -> Result<T, String> {
  let runTask = async () => .ok(await task())
  let runTimer = async () => {
    await Timer.delay(ms)
    return .err("Timeout after ${ms}ms")
  }
  let result = await race(runTask(), runTimer())
  return result
}

// === Debounce & Throttle ===

struct Debouncer<T> {
  delayMs: Int
  lastCall: Int
  pending: Option<T>
}

extension Debouncer {
  static fn new(delayMs: Int) -> Debouncer<T> {
    return Debouncer(delayMs: delayMs, lastCall: 0, pending: .none)
  }

  fn call(value: T, now: Int) -> (Bool, Debouncer<T>) {
    let elapsed = now - self.lastCall
    if elapsed >= self.delayMs {
      return (true, Debouncer(delayMs: self.delayMs, lastCall: now, pending: .none))
    }
    return (false, Debouncer(delayMs: self.delayMs, lastCall: self.lastCall, pending: .some(value)))
  }
}

struct Throttler {
  intervalMs: Int
  lastCall: Int
}

extension Throttler {
  static fn new(intervalMs: Int) -> Throttler {
    return Throttler(intervalMs: intervalMs, lastCall: 0)
  }

  fn canCall(now: Int) -> (Bool, Throttler) {
    let elapsed = now - self.lastCall
    if elapsed >= self.intervalMs {
      return (true, Throttler(intervalMs: self.intervalMs, lastCall: now))
    }
    return (false, self)
  }
}

// === Semaphore ===

struct Semaphore {
  maxConcurrent: Int
  current: Int
}

extension Semaphore {
  static fn new(max: Int) -> Semaphore {
    return Semaphore(maxConcurrent: max, current: 0)
  }

  fn acquire() -> Option<Semaphore> {
    if self.current >= self.maxConcurrent { return .none }
    return .some(Semaphore(maxConcurrent: self.maxConcurrent, current: self.current + 1))
  }

  fn release() -> Semaphore {
    let newCurrent = if self.current > 0 { self.current - 1 } else { 0 }
    return Semaphore(maxConcurrent: self.maxConcurrent, current: newCurrent)
  }

  fn available() -> Int => self.maxConcurrent - self.current
  fn isFull() -> Bool => self.current >= self.maxConcurrent
}

// === RateLimiter ===

struct RateLimiter {
  maxRequests: Int
  windowMs: Int
  timestamps: List<Int>
}

extension RateLimiter {
  static fn new(maxRequests: Int, windowMs: Int) -> RateLimiter {
    return RateLimiter(maxRequests: maxRequests, windowMs: windowMs, timestamps: [])
  }

  fn check(now: Int) -> (Bool, RateLimiter) {
    // Remove expired timestamps
    var valid: List<Int> = []
    for ts in self.timestamps {
      if now - ts < self.windowMs {
        valid = valid + [ts]
      }
    }
    if valid.length >= self.maxRequests {
      return (false, RateLimiter(maxRequests: self.maxRequests, windowMs: self.windowMs, timestamps: valid))
    }
    return (true, RateLimiter(
      maxRequests: self.maxRequests,
      windowMs: self.windowMs,
      timestamps: valid + [now]
    ))
  }

  fn remaining(now: Int) -> Int {
    var count = 0
    for ts in self.timestamps {
      if now - ts < self.windowMs { count += 1 }
    }
    return self.maxRequests - count
  }

  fn resetAt(now: Int) -> Int {
    if self.timestamps.length == 0 { return now }
    return self.timestamps[0] + self.windowMs
  }
}

// === Pool ===

struct Pool<T> {
  available: List<T>
  maxSize: Int
}

extension Pool {
  static fn new(items: List<T>) -> Pool<T> {
    return Pool(available: items, maxSize: items.length)
  }

  fn acquire() -> Option<(T, Pool<T>)> {
    if self.available.length == 0 { return .none }
    let item = self.available[0]
    let rest = self.available.slice(1)
    return .some((item, Pool(available: rest, maxSize: self.maxSize)))
  }

  fn release(item: T) -> Pool<T> {
    if self.available.length >= self.maxSize { return self }
    return Pool(available: self.available + [item], maxSize: self.maxSize)
  }

  fn size() -> Int => self.available.length
  fn isEmpty() -> Bool => self.available.length == 0
}
