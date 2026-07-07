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
}

extension Logger {
  static fn new(name: String) -> Logger {
    return Logger(level: .info, name: name, useColors: true)
  }

  fn withLevel(level: LogLevel) -> Logger {
    return self.{ level: level }
  }

  fn withColors(enabled: Bool) -> Logger {
    return self.{ useColors: enabled }
  }

  fn debug(msg: String) {
    self._writeLog(.debug, msg, "")
  }

  fn debugCtx(msg: String, ctx: String) {
    self._writeLog(.debug, msg, ctx)
  }

  fn info(msg: String) {
    self._writeLog(.info, msg, "")
  }

  fn infoCtx(msg: String, ctx: String) {
    self._writeLog(.info, msg, ctx)
  }

  fn warn(msg: String) {
    self._writeLog(.warn, msg, "")
  }

  fn warnCtx(msg: String, ctx: String) {
    self._writeLog(.warn, msg, ctx)
  }

  fn error(msg: String) {
    self._writeLog(.error, msg, "")
  }

  fn errorCtx(msg: String, ctx: String) {
    self._writeLog(.error, msg, ctx)
  }

  fn fatal(msg: String) {
    self._writeLog(.fatal, msg, "")
  }

  fn _writeLog(level: LogLevel, msg: String, ctx: String) {
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
