// Regressão de runtime: async (só o determinístico)
// Exercita structs puros que recebem `now: Int` explícito ou estado imutável:
//   Semaphore (acquire/release/available/isFull), Debouncer (call),
//   Throttler (canCall), RateLimiter (check/remaining/resetAt), Pool.
// NÃO exercita retry/retryWithBackoff/timeout (usam Timer.delay = tempo real).
import { Semaphore, Debouncer, Throttler, RateLimiter, Pool } from "async"

fn main() {
  let sem = Semaphore.new(2)
  match sem.acquire() {
    .some(s) => println("acquired, available = " + s.available().toString()),
    .none => println("full")
  }
  println("isFull(empty) = " + sem.isFull().toString())
  let sem2 = sem.release()
  println("release available = " + sem2.available().toString())

  // Debouncer: com `now` explícito é puro
  let deb = Debouncer.new(100)
  let d1 = deb.call("x", 0)
  println("debounce first(now=0) = " + d1.0.toString())
  let deb2 = d1.1
  let d2 = deb2.call("y", 50)
  println("debounce within window = " + d2.0.toString())
  let d3 = deb2.call("z", 200)
  println("debounce after window = " + d3.0.toString())

  // Throttler
  let th = Throttler.new(100)
  let t1 = th.canCall(0)
  println("throttle first = " + t1.0.toString())
  let t2 = t1.1.canCall(50)
  println("throttle within = " + t2.0.toString())

  // RateLimiter: janela de 1000ms, máx 2
  let rl = RateLimiter.new(2, 1000)
  let a = rl.check(0)
  let b = a.1.check(100)
  let c = b.1.check(200)
  println("rate 1st allowed = " + a.0.toString())
  println("rate 2nd allowed = " + b.0.toString())
  println("rate 3rd allowed = " + c.0.toString())
  println("rate remaining = " + b.1.remaining(200).toString())

  // Pool
  let pool = Pool.new([10, 20, 30])
  println("pool size = " + pool.size().toString())
  match pool.acquire() {
    .some(pair) => println("pool acquire = " + pair.0.toString()),
    .none => println("empty")
  }
}
