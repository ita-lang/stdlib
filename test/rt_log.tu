// Regressão de runtime: log
// Exercita: Logger.new, withColors(false), withLevel, info/warn/error/debug,
//           infoCtx. A struct Logger NÃO imprime timestamp → determinístico.
// IMPORTANTE: a variável se chama `applog`, NÃO `log`. `log` colide com o
// namespace built-in `log` (logger async com timestamp) e quebra a resolução
// dos métodos da struct (NoSuchMethodError / saída não-determinística).
import { Logger } from "log"

fn main() {
  let applog = Logger.new("app").withColors(false)
  applog.info("server started")
  applog.warn("low memory")
  applog.error("connection failed")
  applog.debug("hidden at info level")

  // withLevel(.debug) faz o debug aparecer; infoCtx anexa contexto
  let dbg = Logger.new("db").withColors(false).withLevel(.debug)
  dbg.debug("verbose on")
  dbg.infoCtx("query done", "reqId=42")
  dbg.warnCtx("slow query", "ms=1200")
}
