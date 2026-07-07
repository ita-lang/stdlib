// Regressão de runtime: cache
// Exercita: Cache.new/withTtl, set, get, has, size, delete, clear,
//           getOrSet, prune (todos com `now` explícito → determinístico)
import { Cache } from "cache"

fn describe(label: String, o: Option<Int>) {
  match o {
    .some(x) => println(label + " => some(" + x.toString() + ")"),
    .none => println(label + " => none")
  }
}

fn main() {
  let c0 = Cache.new(3)
  let c1 = c0.set("a", 1, 0)
  let c2 = c1.set("b", 2, 0)
  describe("get a", c2.get("a", 0))
  describe("get b", c2.get("b", 0))
  describe("get x", c2.get("x", 0))
  println("size => " + c2.size().toString())
  println("has a => " + c2.has("a", 0).toString())
  println("has x => " + c2.has("x", 0).toString())

  let c3 = c2.delete("a")
  describe("after delete get a", c3.get("a", 0))
  println("size after delete => " + c3.size().toString())

  let c4 = c2.clear()
  println("size after clear => " + c4.size().toString())

  // getOrSet: miss computa e grava; hit retorna sem recomputar
  let r1 = c2.getOrSet("c", 0, () => 99)
  println("getOrSet miss value => " + r1.0.toString())
  println("getOrSet cache size => " + r1.1.size().toString())

  // TTL: entrada expira quando (now - createdAt) > ttlMs
  let t0 = Cache.withTtl(3, 100)
  let t1 = t0.set("k", 7, 0)
  describe("ttl get within window", t1.get("k", 50))
  describe("ttl get after expiry", t1.get("k", 200))
  let t2 = t1.prune(200)
  println("size after prune => " + t2.size().toString())
}
