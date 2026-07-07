// Regressão de runtime: server
// Exercita: App.new, get/post (registro de rota), handle(req sintético) →
//           status/body, matching de rota com param (:id) → 200,
//           404 em rota inexistente, Response factories
//           (ok/json/notFound/redirect/created), parseQuery.
//           Request construído à mão → sem rede, determinístico.
// NOTA: o handler da rota :id NÃO lê req.params.get("id") — esse caminho
// crasha no codegen atual (`_Map has no method 'get'` no map de params vindo
// do copy-with). O matching da rota em si funciona (retorna 200). Bug da
// stdlib/compilador; ler o param de volta quando corrigido.
import { App, Request, Response, parseQuery } from "server"

fn req(method: String, path: String) -> Request {
  return Request(method: method, path: path, headers: {}, body: "", params: {}, query: {})
}

fn main() {
  var app = App.new()
  app = app.get("/hello", (r) => Response.ok("Hello!"))
  app = app.get("/users/:id", (r) => Response.ok("user-matched"))
  app = app.post("/users", (r) => Response.created("{\"created\":true}"))
  println("app port = " + app.port.toString())

  let h = app.handle(req("GET", "/hello"))
  println("hello status = " + h.status.toString())
  println("hello body = " + h.body)

  let u = app.handle(req("GET", "/users/42"))
  println("user status = " + u.status.toString())
  println("user body = " + u.body)   // rota :id casou → user-matched

  let created = app.handle(req("POST", "/users"))
  println("created status = " + created.status.toString())

  let miss = app.handle(req("GET", "/nope"))
  println("miss status = " + miss.status.toString())

  // Response factories
  let ok = Response.ok("test")
  println("ok status = " + ok.status.toString())
  println("ok body = " + ok.body)
  println("json status = " + Response.json("{}").status.toString())
  println("notFound status = " + Response.notFound("nope").status.toString())
  println("redirect status = " + Response.redirect("/x").status.toString())

  // parseQuery
  let q = parseQuery("a=1&b=2")
  match q.get("a") {
    .some(v) => println("query a = " + v),
    .none => println("none")
  }
  match q.get("b") {
    .some(v) => println("query b = " + v),
    .none => println("none")
  }
}
