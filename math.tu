// Foundation: Math
// Funções matemáticas puras para Glu

// === Constants ===

let pi = 3.14159265358979323846
let e = 2.71828182845904523536
let tau = 6.28318530717958647692
let infinity = 1.0 / 0.0

// === Basic ===

fn abs(x: Int) -> Int => match x { _ if x < 0 => -x, _ => x }
fn absf(x: Float) -> Float => match x { _ if x < 0.0 => -x, _ => x }

fn min(a: Int, b: Int) -> Int => match a { _ if a < b => a, _ => b }
fn max(a: Int, b: Int) -> Int => match a { _ if a > b => a, _ => b }
fn minf(a: Float, b: Float) -> Float => match a { _ if a < b => a, _ => b }
fn maxf(a: Float, b: Float) -> Float => match a { _ if a > b => a, _ => b }

fn clamp(value: Int, low: Int, high: Int) -> Int => min(max(value, low), high)
fn clampf(value: Float, low: Float, high: Float) -> Float => minf(maxf(value, low), high)

fn lerp(a: Float, b: Float, t: Float) -> Float => a + (b - a) * t

// === Aggregation ===

fn sum(list: List<Int>) -> Int {
  var acc = 0
  for item in list {
    acc += item
  }
  return acc
}

fn sumf(list: List<Float>) -> Float {
  var acc = 0.0
  for item in list {
    acc += item
  }
  return acc
}

fn avg(list: List<Int>) -> Float {
  if list.length == 0 { return 0.0 }
  return sum(list) / list.length
}

fn avgf(list: List<Float>) -> Float {
  if list.length == 0 { return 0.0 }
  return sumf(list) / list.length
}

// === Number Theory ===

fn gcd(a: Int, b: Int) -> Int {
  var x = abs(a)
  var y = abs(b)
  while y != 0 {
    let temp = y
    y = x % y
    x = temp
  }
  return x
}

fn lcm(a: Int, b: Int) -> Int {
  if a == 0 && b == 0 { return 0 }
  return abs(a * b) / gcd(a, b)
}

fn isPrime(n: Int) -> Bool {
  if n < 2 { return false }
  if n < 4 { return true }
  if n % 2 == 0 { return false }
  if n % 3 == 0 { return false }
  var i = 5
  while i * i <= n {
    if n % i == 0 { return false }
    if n % (i + 2) == 0 { return false }
    i += 6
  }
  return true
}

fn fibonacci(n: Int) -> Int {
  if n <= 0 { return 0 }
  if n == 1 { return 1 }
  var a = 0
  var b = 1
  var i = 2
  while i <= n {
    let temp = a + b
    a = b
    b = temp
    i += 1
  }
  return b
}

fn factorial(n: Int) -> Int {
  if n <= 1 { return 1 }
  var result = 1
  var i = 2
  while i <= n {
    result *= i
    i += 1
  }
  return result
}

// === Powers & Roots ===

fn pow(base: Int, exp: Int) -> Int {
  if exp == 0 { return 1 }
  if exp < 0 { return 0 }
  var result = 1
  var b = base
  var e = exp
  while e > 0 {
    if e % 2 == 1 {
      result *= b
    }
    b *= b
    e = e / 2
  }
  return result
}

fn isqrt(n: Int) -> Int {
  if n < 0 { return 0 }
  if n == 0 { return 0 }
  var x = n
  var y = (x + 1) / 2
  while y < x {
    x = y
    y = (x + n / x) / 2
  }
  return x
}

// === Sequences ===

fn range(start: Int, end: Int) -> List<Int> {
  var result: List<Int> = []
  var i = start
  while i < end {
    result = result + [i]
    i += 1
  }
  return result
}

fn rangeStep(start: Int, end: Int, step: Int) -> List<Int> {
  var result: List<Int> = []
  var i = start
  if step > 0 {
    while i < end {
      result = result + [i]
      i += step
    }
  } else if step < 0 {
    while i > end {
      result = result + [i]
      i += step
    }
  }
  return result
}

// === Conversions ===

fn toRadians(degrees: Float) -> Float => degrees * pi / 180.0
fn toDegrees(radians: Float) -> Float => radians * 180.0 / pi

// === Sign ===

fn sign(x: Int) -> Int {
  if x > 0 { return 1 }
  if x < 0 { return -1 }
  return 0
}

fn signf(x: Float) -> Float {
  if x > 0.0 { return 1.0 }
  if x < 0.0 { return -1.0 }
  return 0.0
}

fn isEven(n: Int) -> Bool => n % 2 == 0
fn isOdd(n: Int) -> Bool => n % 2 != 0
