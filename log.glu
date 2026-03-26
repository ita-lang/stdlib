// Foundation: Log
// Logging estruturado com níveis, cores e contexto

enum LogLevel {
  debug,
  info,
  warn,
  error,
  fatal
}

struct Logger {
  level: LogLevel
  name: String
  useColors: Bool

  fn new(name: String) -> Logger {
    return Logger { level: .info, name: name, useColors: true }
  }

  fn withLevel(self, level: LogLevel) -> Logger {
    return self.{ level: level }
  }

  fn withColors(self, enabled: Bool) -> Logger {
    return self.{ useColors: enabled }
  }

  fn debug(self, msg: String) {
    self._log(.debug, msg, "")
  }

  fn debugCtx(self, msg: String, ctx: String) {
    self._log(.debug, msg, ctx)
  }

  fn info(self, msg: String) {
    self._log(.info, msg, "")
  }

  fn infoCtx(self, msg: String, ctx: String) {
    self._log(.info, msg, ctx)
  }

  fn warn(self, msg: String) {
    self._log(.warn, msg, "")
  }

  fn warnCtx(self, msg: String, ctx: String) {
    self._log(.warn, msg, ctx)
  }

  fn error(self, msg: String) {
    self._log(.error, msg, "")
  }

  fn errorCtx(self, msg: String, ctx: String) {
    self._log(.error, msg, ctx)
  }

  fn fatal(self, msg: String) {
    self._log(.fatal, msg, "")
  }

  fn _log(self, level: LogLevel, msg: String, ctx: String) {
    if _levelValue(level) < _levelValue(self.level) { return }
    let prefix = _levelPrefix(level, self.useColors)
    let nameTag = if self.name.length > 0 { "[${self.name}] " } else { "" }
    let ctxTag = if ctx.length > 0 { " | ${ctx}" } else { "" }
    let reset = if self.useColors { "\x1b[0m" } else { "" }
    print("${prefix} ${nameTag}${msg}${ctxTag}${reset}")
  }
}

fn _levelValue(level: LogLevel) -> Int {
  match level {
    .debug => 0,
    .info => 1,
    .warn => 2,
    .error => 3,
    .fatal => 4
  }
}

fn _levelPrefix(level: LogLevel, colors: Bool) -> String {
  if colors {
    match level {
      .debug => "\x1b[90m[DEBUG]",
      .info => "\x1b[36m[INFO] ",
      .warn => "\x1b[33m[WARN] ",
      .error => "\x1b[31m[ERROR]",
      .fatal => "\x1b[35m[FATAL]"
    }
  } else {
    match level {
      .debug => "[DEBUG]",
      .info => "[INFO] ",
      .warn => "[WARN] ",
      .error => "[ERROR]",
      .fatal => "[FATAL]"
    }
  }
}
