// Regressão de runtime: math
// Exercita: abs, clamp, lerp, gcd, lcm, isPrime, fibonacci, pow, factorial,
//           isqrt, sum, min, max, sign, isEven, isOdd, range, rangeStep, pi, e
import { abs, clamp, lerp, gcd, lcm, isPrime, fibonacci, pow, factorial, isqrt, sum, min, max, sign, isEven, isOdd, range, rangeStep, pi, e } from "math"

fn main() {
  println("abs(-5) = " + abs(-5).toString())
  println("clamp(15,0,10) = " + clamp(15, 0, 10).toString())
  println("lerp(0,10,0.5) = " + lerp(0.0, 10.0, 0.5).toString())
  println("gcd(12,18) = " + gcd(12, 18).toString())
  println("lcm(4,6) = " + lcm(4, 6).toString())
  println("isPrime(17) = " + isPrime(17).toString())
  println("isPrime(18) = " + isPrime(18).toString())
  println("fibonacci(10) = " + fibonacci(10).toString())
  println("pow(2,10) = " + pow(2, 10).toString())
  println("factorial(5) = " + factorial(5).toString())
  println("isqrt(50) = " + isqrt(50).toString())
  println("sum([1..5]) = " + sum([1, 2, 3, 4, 5]).toString())
  println("min(3,7) = " + min(3, 7).toString())
  println("max(3,7) = " + max(3, 7).toString())
  println("sign(-3) = " + sign(-3).toString())
  println("isEven(4) = " + isEven(4).toString())
  println("isOdd(4) = " + isOdd(4).toString())
  println("range(1,5) = " + range(1, 5).toString())
  println("rangeStep(0,10,2) = " + rangeStep(0, 10, 2).toString())
  println("pi = " + pi.toString())
  println("e = " + e.toString())
}
