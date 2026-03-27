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

  fn ok(body: String) -> Response {
    return Response { status: 200, headers: { "Content-Type": "text/plain" }, body: body }
  }

  fn json(data: String) -> Response {
    return Response { status: 200, headers: { "Content-Type": "application/json" }, body: data }
  }

  fn html(content: String) -> Response {
    return Response { status: 200, headers: { "Content-Type": "text/html" }, body: content }
  }

  fn created(body: String) -> Response {
    return Response { status: 201, headers: { "Content-Type": "application/json" }, body: body }
  }

  fn noContent() -> Response {
    return Response { status: 204, headers: {}, body: "" }
  }

  fn badRequest(msg: String) -> Response {
    return Response { status: 400, headers: { "Content-Type": "application/json" }, body: "{\"error\": \"${msg}\"}" }
  }

  fn unauthorized(msg: String) -> Response {
    return Response { status: 401, headers: { "Content-Type": "application/json" }, body: "{\"error\": \"${msg}\"}" }
  }

  fn forbidden(msg: String) -> Response {
    return Response { status: 403, headers: { "Content-Type": "application/json" }, body: "{\"error\": \"${msg}\"}" }
  }

  fn notFound(msg: String) -> Response {
    return Response { status: 404, headers: { "Content-Type": "application/json" }, body: "{\"error\": \"${msg}\"}" }
  }

  fn serverError(msg: String) -> Response {
    return Response { status: 500, headers: { "Content-Type": "application/json" }, body: "{\"error\": \"${msg}\"}" }
  }

  fn redirect(url: String) -> Response {
    return Response { status: 302, headers: { "Location": url }, body: "" }
  }

  fn withHeader(self, key: String, value: String) -> Response {
    return self.{ headers: self.headers.set(key, value) }
  }

  fn withStatus(self, code: Int) -> Response {
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
    let {allowed, updated} = limiter.check(now)
    if !allowed {
      return .err(Response { status: 429, headers: {}, body: "{\"error\": \"Too many requests\"}" })
    }
    return .ok(req)
  }
}

pub fn requireHeader(name: String) -> (Request) -> Result<Request, Response> {
  return (req) => {
    match req.headers.get(name) {
      .some(_) => .ok(req),
      .none => .err(Response.badRequest("Missing header: ${name}"))
    }
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
    let {allowed, updated} = limiter.check(now)
    if !allowed {
      return .err(Response {
        status: 429,
        headers: { "Retry-After": "60" },
        body: "{\"error\": \"Too many attempts for key: ${key}. Try again later.\"}"
      })
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
  return (req) => {
    match req.headers.get("Content-Type") {
      .some(ct) => {
        if ct == expected || ct.startsWith(expected) {
          return .ok(req)
        }
        return .err(Response.badRequest("Expected Content-Type: ${expected}"))
      },
      .none => .err(Response.badRequest("Missing Content-Type header"))
    }
  }
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
  return (req) => {
    match req.headers.get("Authorization") {
      .some(auth) => {
        if auth.startsWith("Bearer ") {
          return .ok(req)
        }
        return .err(Response.unauthorized("Invalid auth format"))
      },
      .none => .err(Response.unauthorized("Missing Authorization header"))
    }
  }
}

// === Router ===

struct Router {
  prefix: String
  routes: List<Route>
  middlewares: List<(Request) -> Result<Request, Response>>

  fn new() -> Router {
    return Router { prefix: "", routes: [], middlewares: [] }
  }

  fn group(prefix: String) -> Router {
    return Router { prefix: prefix, routes: [], middlewares: [] }
  }

  fn use(self, middleware: (Request) -> Result<Request, Response>) -> Router {
    return self.{ middlewares: self.middlewares + [middleware] }
  }

  fn get(self, path: String, handler: (Request) -> Response) -> Router {
    let route = Route { method: .GET, pattern: self.prefix + path, handler: handler, middlewares: self.middlewares }
    return self.{ routes: self.routes + [route] }
  }

  fn post(self, path: String, handler: (Request) -> Response) -> Router {
    let route = Route { method: .POST, pattern: self.prefix + path, handler: handler, middlewares: self.middlewares }
    return self.{ routes: self.routes + [route] }
  }

  fn put(self, path: String, handler: (Request) -> Response) -> Router {
    let route = Route { method: .PUT, pattern: self.prefix + path, handler: handler, middlewares: self.middlewares }
    return self.{ routes: self.routes + [route] }
  }

  fn patch(self, path: String, handler: (Request) -> Response) -> Router {
    let route = Route { method: .PATCH, pattern: self.prefix + path, handler: handler, middlewares: self.middlewares }
    return self.{ routes: self.routes + [route] }
  }

  fn delete(self, path: String, handler: (Request) -> Response) -> Router {
    let route = Route { method: .DELETE, pattern: self.prefix + path, handler: handler, middlewares: self.middlewares }
    return self.{ routes: self.routes + [route] }
  }

  fn mount(self, other: Router) -> Router {
    return self.{ routes: self.routes + other.routes }
  }
}

// === App ===

struct App {
  router: Router
  globalMiddlewares: List<(Request) -> Result<Request, Response>>
  port: Int

  fn new() -> App {
    return App { router: Router.new(), globalMiddlewares: [], port: 3000 }
  }

  fn use(self, middleware: (Request) -> Result<Request, Response>) -> App {
    return self.{ globalMiddlewares: self.globalMiddlewares + [middleware] }
  }

  fn get(self, path: String, handler: (Request) -> Response) -> App {
    return self.{ router: self.router.get(path, handler) }
  }

  fn post(self, path: String, handler: (Request) -> Response) -> App {
    return self.{ router: self.router.post(path, handler) }
  }

  fn put(self, path: String, handler: (Request) -> Response) -> App {
    return self.{ router: self.router.put(path, handler) }
  }

  fn patch(self, path: String, handler: (Request) -> Response) -> App {
    return self.{ router: self.router.patch(path, handler) }
  }

  fn delete(self, path: String, handler: (Request) -> Response) -> App {
    return self.{ router: self.router.delete(path, handler) }
  }

  fn mount(self, prefix: String, router: Router) -> App {
    // Add prefix to all router routes
    var prefixed = Router.new()
    for route in router.routes {
      let newRoute = Route {
        method: route.method,
        pattern: prefix + route.pattern,
        handler: route.handler,
        middlewares: route.middlewares
      }
      prefixed = prefixed.{ routes: prefixed.routes + [newRoute] }
    }
    return self.{ router: self.router.mount(prefixed) }
  }

  fn listen(self, port: Int) -> App {
    print("[Server] Listening on http://localhost:${port}")
    return self.{ port: port }
  }

  fn handle(self, req: Request) -> Response {
    // Run global middlewares
    var currentReq = req
    for mw in self.globalMiddlewares {
      match mw(currentReq) {
        .ok(r) => currentReq = r,
        .err(response) => return response
      }
    }

    // Find matching route
    for route in self.router.routes {
      if _methodMatches(route.method, currentReq.method) {
        match _matchRoute(route.pattern, currentReq.path) {
          .some(params) => {
            let reqWithParams = currentReq.{ params: params }

            // Run route middlewares
            var mwReq = reqWithParams
            for mw in route.middlewares {
              match mw(mwReq) {
                .ok(r) => mwReq = r,
                .err(response) => return response
              }
            }

            return route.handler(mwReq)
          },
          .none => {}
        }
      }
    }

    return Response.notFound("Route not found: ${req.method} ${req.path}")
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
