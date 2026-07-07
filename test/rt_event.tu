// Regressão de runtime: event
// Exercita: Emitter.new, on, once, off, dispatch, listenerCount, removeAll.
// Handlers imprimem em ordem determinística.
// NOTA: EventBus está omitido de propósito — EventBus.on crasha no codegen
// atual (`Emitter<dynamic> is not a subtype of Emitter<String>`, variância de
// genéricos). Bug da stdlib/compilador; reintroduzir quando corrigido.
import { Emitter } from "event"

fn main() {
  var em = Emitter.new()
  let r = em.on((v) => println("listener A got: " + v))
  em = r.1
  println("listeners = " + em.listenerCount().toString())
  em = em.dispatch("hello")
  em = em.dispatch("world")

  // once: dispara uma vez e é removido
  let r2 = em.once((v) => println("once got: " + v))
  em = r2.1
  println("listeners with once = " + em.listenerCount().toString())
  em = em.dispatch("first")
  println("listeners after once fired = " + em.listenerCount().toString())
  em = em.dispatch("second")

  // off remove por id
  let idA = r.0
  em = em.off(idA)
  println("listeners after off = " + em.listenerCount().toString())

  // removeAll
  em = em.removeAll()
  println("listeners after removeAll = " + em.listenerCount().toString())
}
