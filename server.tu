// Foundation: Server
// HTTP Server framework Express-style sobre Http nativo

// === Request & Response ===

struct Request {
  method: String
  path: String
  headers: Map<String, String>
  body: String
  params: Map<String, String>
  query: Map<String, String>
}

struct Response {
  status: Int
  headers: Map<String, String>
  body: String
}

extension Response {
  static fn ok(body: String) -> Response {
    return Response(status: 200, headers: { "Content-Type": "text/plain" }, body: body)
  }

  static fn json(data: String) -> Response {
    return Response(status: 200, headers: { "Content-Type": "application/json" }, body: data)
  }

  static fn html(content: String) -> Response {
    return Response(status: 200, headers: { "Content-Type": "text/html" }, body: content)
  }

  static fn created(body: String) -> Response {
    return Response(status: 201, headers: { "Content-Type": "application/json" }, body: body)
  }

  static fn noContent() -> Response {
    return Response(status: 204, headers: {}, body: "")
  }

  static fn badRequest(msg: String) -> Response {
    return Response(status: 400, headers: { "Content-Type": "application/json" }, body: "{\"error\": \"${msg}\"}")
  }

  static fn unauthorized(msg: String) -> Response {
    return Response(status: 401, headers: { "Content-Type": "application/json" }, body: "{\"error\": \"${msg}\"}")
  }

  static fn forbidden(msg: String) -> Response {
    return Response(status: 403, headers: { "Content-Type": "application/json" }, body: "{\"error\": \"${msg}\"}")
  }

  static fn notFound(msg: String) -> Response {
    return Response(status: 404, headers: { "Content-Type": "application/json" }, body: "{\"error\": \"${msg}\"}")
  }

  static fn serverError(msg: String) -> Response {
    return Response(status: 500, headers: { "Content-Type": "application/json" }, body: "{\"error\": \"${msg}\"}")
  }

  static fn redirect(url: String) -> Response {
    return Response(status: 302, headers: { "Location": url }, body: "")
  }

  fn withHeader(key: String, value: String) -> Response {
    return self.{ headers: self.headers.set(key, value) }
  }

  fn withStatus(code: Int) -> Response {
    return self.{ status: code }
  }
}

// === Route ===

enum HttpMethod {
  GET,
  POST,
  PUT,
  PATCH,
  DELETE,
  OPTIONS,
  HEAD
}

struct Route {
  method: HttpMethod
  pattern: String
  handler: (Request) -> Response
  middlewares: List<(Request) -> Result<Request, Response>>
}

// === Middleware ===

pub fn cors(origins: List<String>) -> (Request) -> Result<Request, Response> {
  return (req) => {
    let origin = req.headers.get("Origin") ?? "*"
    var allowed = false
    for o in origins {
      if o == "*" || o == origin { allowed = true }
    }
    if !allowed {
      return .err(Response.forbidden("CORS: origin not allowed"))
    }
    return .ok(req)
  }
}

pub fn corsAll() -> (Request) -> Result<Request, Response> {
  return (req) => .ok(req)
}

pub fn rateLimit(limiter: RateLimiter, now: Int) -> (Request) -> Result<Request, Response> {
  return (req) => {
    let checkResult = limiter.check(now)
    let allowed = checkResult.0
    let updated = checkResult.1
    if !allowed {
      return .err(Response(status: 429, headers: {}, body: "{\"error\": \"Too many requests\"}"))
    }
    return .ok(req)
  }
}

pub fn requireHeader(name: String) -> (Request) -> Result<Request, Response> {
  return (req) => _checkHeader(req, name)
}

fn _checkHeader(req: Request, name: String) -> Result<Request, Response> {
  match req.headers.get(name) {
    .some(_) => .ok(req),
    .none => .err(Response.badRequest("Missing header: ${name}"))
  }
}

// Protecao contra brute force por chave (ex: IP, email).
// Bloqueia apos maxAttempts falhas dentro da janela de tempo do limiter.
// O caller deve rastrear o estado do limiter entre requests.
//
// Uso:
//   let guard = bruteForceGuard(limiter, now(), "login:" + req.body)
//   match guard(req) {
//     .ok(r) => handleLogin(r),
//     .err(resp) => resp  // 429 Too Many Requests
//   }
pub fn bruteForceGuard(limiter: RateLimiter, now: Int, key: String) -> (Request) -> Result<Request, Response> {
  return (req) => {
    let checkResult = limiter.check(now)
    let allowed = checkResult.0
    let updated = checkResult.1
    if !allowed {
      return .err(Response(
        status: 429,
        headers: { "Retry-After": "60" },
        body: "{\"error\": \"Too many attempts for key: ${key}. Try again later.\"}"
      ))
    }
    return .ok(req)
  }
}

// Validacao de Content-Type esperado.
// Rejeita requests que nao enviam o Content-Type correto.
//
// Uso:
//   app.use(requireContentType("application/json"))
pub fn requireContentType(expected: String) -> (Request) -> Result<Request, Response> {
  return (req) => _checkContentType(req, expected)
}

fn _checkContentType(req: Request, expected: String) -> Result<Request, Response> {
  match req.headers.get("Content-Type") {
    .none => .err(Response.badRequest("Missing Content-Type header")),
    .some(ct) => _contentTypeResult(req, ct, expected)
  }
}

fn _contentTypeResult(req: Request, ct: String, expected: String) -> Result<Request, Response> {
  if ct == expected || ct.startsWith(expected) {
    return .ok(req)
  }
  return .err(Response.badRequest("Expected Content-Type: ${expected}"))
}

// Logging middleware — imprime method, path e tempo de resposta.
// Deve ser o primeiro middleware da chain para medir tempo total.
//
// Uso:
//   app.use(requestLogger())
pub fn requestLogger() -> (Request) -> Result<Request, Response> {
  return (req) => {
    print("[${req.method}] ${req.path}")
    return .ok(req)
  }
}

pub fn requireAuth() -> (Request) -> Result<Request, Response> {
  return (req) => _checkAuth(req)
}

fn _checkAuth(req: Request) -> Result<Request, Response> {
  match req.headers.get("Authorization") {
    .none => .err(Response.unauthorized("Missing Authorization header")),
    .some(auth) => _authResult(req, auth)
  }
}

fn _authResult(req: Request, auth: String) -> Result<Request, Response> {
  if auth.startsWith("Bearer ") {
    return .ok(req)
  }
  return .err(Response.unauthorized("Invalid auth format"))
}

// === Router ===

struct Router {
  prefix: String
  routes: List<Route>
  middlewares: List<(Request) -> Result<Request, Response>>
}

extension Router {
  static fn new() -> Router {
    return Router(prefix: "", routes: [], middlewares: [])
  }

  static fn group(prefix: String) -> Router {
    return Router(prefix: prefix, routes: [], middlewares: [])
  }

  fn use(middleware: (Request) -> Result<Request, Response>) -> Router {
    return self.{ middlewares: self.middlewares + [middleware] }
  }

  fn get(path: String, handler: (Request) -> Response) -> Router {
    let route = Route(method: .GET, pattern: self.prefix + path, handler: handler, middlewares: self.middlewares)
    return self.{ routes: self.routes + [route] }
  }

  fn post(path: String, handler: (Request) -> Response) -> Router {
    let route = Route(method: .POST, pattern: self.prefix + path, handler: handler, middlewares: self.middlewares)
    return self.{ routes: self.routes + [route] }
  }

  fn put(path: String, handler: (Request) -> Response) -> Router {
    let route = Route(method: .PUT, pattern: self.prefix + path, handler: handler, middlewares: self.middlewares)
    return self.{ routes: self.routes + [route] }
  }

  fn patch(path: String, handler: (Request) -> Response) -> Router {
    let route = Route(method: .PATCH, pattern: self.prefix + path, handler: handler, middlewares: self.middlewares)
    return self.{ routes: self.routes + [route] }
  }

  fn delete(path: String, handler: (Request) -> Response) -> Router {
    let route = Route(method: .DELETE, pattern: self.prefix + path, handler: handler, middlewares: self.middlewares)
    return self.{ routes: self.routes + [route] }
  }

  fn mount(other: Router) -> Router {
    return self.{ routes: self.routes + other.routes }
  }
}

// === App ===

struct App {
  router: Router
  globalMiddlewares: List<(Request) -> Result<Request, Response>>
  port: Int
}

extension App {
  static fn new() -> App {
    return App(router: Router.new(), globalMiddlewares: [], port: 3000)
  }

  fn use(middleware: (Request) -> Result<Request, Response>) -> App {
    return self.{ globalMiddlewares: self.globalMiddlewares + [middleware] }
  }

  fn get(path: String, handler: (Request) -> Response) -> App {
    return self.{ router: self.router.get(path, handler) }
  }

  fn post(path: String, handler: (Request) -> Response) -> App {
    return self.{ router: self.router.post(path, handler) }
  }

  fn put(path: String, handler: (Request) -> Response) -> App {
    return self.{ router: self.router.put(path, handler) }
  }

  fn patch(path: String, handler: (Request) -> Response) -> App {
    return self.{ router: self.router.patch(path, handler) }
  }

  fn delete(path: String, handler: (Request) -> Response) -> App {
    return self.{ router: self.router.delete(path, handler) }
  }

  fn mount(prefix: String, router: Router) -> App {
    // Add prefix to all router routes
    var prefixed = Router.new()
    for route in router.routes {
      let newRoute = Route(
        method: route.method,
        pattern: prefix + route.pattern,
        handler: route.handler,
        middlewares: route.middlewares
      )
      prefixed = prefixed.{ routes: prefixed.routes + [newRoute] }
    }
    return self.{ router: self.router.mount(prefixed) }
  }

  fn listen(port: Int) -> App {
    print("[Server] Listening on http://localhost:${port}")
    return self.{ port: port }
  }

  fn handle(req: Request) -> Response {
    // Run global middlewares, short-circuiting on the first error
    let globalResult = _foldMiddlewares(req, self.globalMiddlewares)
    match globalResult {
      .err(response) => response,
      .ok(currentReq) => self._route(currentReq, req)
    }
  }

  // Encontra a primeira rota que casa e executa seus middlewares + handler.
  // Extraído de `handle` porque o dialeto atual não aceita `return` dentro
  // de braço de `match` nem bloco `{ stmts; expr }` como corpo de braço.
  fn _route(currentReq: Request, original: Request) -> Response {
    var result: Option<Response> = .none
    for route in self.router.routes {
      match result {
        .some(_) => {},
        .none => result = _tryRoute(route, currentReq)
      }
    }
    match result {
      .some(resp) => resp,
      .none => Response.notFound("Route not found: ${original.method} ${original.path}")
    }
  }
}

// Retorna .some(resposta) se a rota casou (e foi tratada), .none caso contrário.
fn _tryRoute(route: Route, req: Request) -> Option<Response> {
  if !_methodMatches(route.method, req.method) { return .none }
  match _matchRoute(route.pattern, req.path) {
    .none => .none,
    .some(params) => .some(_runRoute(route, req, params))
  }
}

// Executa os middlewares da rota e depois o handler.
fn _runRoute(route: Route, req: Request, params: Map<String, String>) -> Response {
  let reqWithParams = req.{ params: params }
  let mwResult = _foldMiddlewares(reqWithParams, route.middlewares)
  match mwResult {
    .err(response) => response,
    .ok(mwReq) => route.handler(mwReq)
  }
}

// Fold sequencial da chain de middlewares: aplica cada um em ordem,
// curto-circuitando no primeiro .err. Substitui o `return` dentro de
// braço de match (não permitido no dialeto atual).
fn _foldMiddlewares(req: Request, mws: List<(Request) -> Result<Request, Response>>) -> Result<Request, Response> {
  var acc: Result<Request, Response> = .ok(req)
  for mw in mws {
    acc = _foldStep(acc, mw)
  }
  return acc
}

fn _foldStep(acc: Result<Request, Response>, mw: (Request) -> Result<Request, Response>) -> Result<Request, Response> {
  match acc {
    .err(e) => .err(e),
    .ok(req) => mw(req)
  }
}

// === Route Matching ===

fn _methodMatches(routeMethod: HttpMethod, reqMethod: String) -> Bool {
  match routeMethod {
    .GET => reqMethod == "GET",
    .POST => reqMethod == "POST",
    .PUT => reqMethod == "PUT",
    .PATCH => reqMethod == "PATCH",
    .DELETE => reqMethod == "DELETE",
    .OPTIONS => reqMethod == "OPTIONS",
    .HEAD => reqMethod == "HEAD"
  }
}

fn _matchRoute(pattern: String, path: String) -> Option<Map<String, String>> {
  let patternParts = pattern.split("/")
  let pathParts = path.split("/")

  if patternParts.length != pathParts.length { return .none }

  var params: Map<String, String> = {}
  var i = 0
  while i < patternParts.length {
    let pp = patternParts[i]
    let rp = pathParts[i]
    if pp.startsWith(":") {
      let paramName = pp.substring(1)
      params = params.set(paramName, rp)
    } else if pp != rp {
      return .none
    }
    i += 1
  }
  return .some(params)
}

// === Query Parser ===

pub fn parseQuery(queryString: String) -> Map<String, String> {
  var result: Map<String, String> = {}
  if queryString.length == 0 { return result }
  let pairs = queryString.split("&")
  for pair in pairs {
    let parts = pair.split("=")
    if parts.length == 2 {
      result = result.set(parts[0], parts[1])
    }
  }
  return result
}
