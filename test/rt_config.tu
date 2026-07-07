// Regressão de runtime: config
// Exercita: Config.new, set, get, getString, getInt, getBool, has, keys.
// NÃO usa Config.env/envInt (leem Env → não determinístico) nem Config.load
// (lê arquivo). merge()/fromMap() estão omitidos: merge crasha no codegen
// atual (`_CompactKeysIterable has no method call` ao iterar other.data.keys()).
// Bug da stdlib/compilador; reintroduzir quando corrigido.
import { Config } from "config"

fn main() {
  let c = Config.new()
  let c2 = c.set("host", "localhost").set("port", "8080").set("debug", "true")
  println("has host = " + c2.has("host").toString())
  println("has nope = " + c2.has("nope").toString())
  println("getString host = " + c2.getString("host", "none"))
  println("getInt port = " + c2.getInt("port", 0).toString())
  println("getInt missing = " + c2.getInt("nope", 42).toString())
  println("getBool debug = " + c2.getBool("debug", false).toString())
  println("getBool missing = " + c2.getBool("nope", false).toString())
  match c2.get("host") {
    .some(v) => println("get host = " + v),
    .none => println("none")
  }
  match c2.get("nope") {
    .some(v) => println("get nope = " + v),
    .none => println("get nope = none")
  }
  println("keys = " + c2.keys().toString())
}
