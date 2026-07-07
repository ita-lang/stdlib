// Regressão de runtime: validate
// Exercita: Schema.string/min/max/email/url + validate → Result (ok/err).
//           Entradas fixas → determinístico.
// NOTA: oneOf(...) e ObjectSchema.validate(map) estão omitidos de propósito —
// ambos crasham no codegen atual por perda de tipo em literais de coleção
// (`List<dynamic> is not List<String>` / `_Map is not Map<String,String>`).
// Bug da stdlib/compilador; reintroduzir quando corrigido.
import { Schema } from "validate"

fn report(label: String, r: Result<String, List<String>>) {
  match r {
    .ok(v) => println(label + " ok: " + v),
    .err(errs) => println(label + " err: " + errs.toString())
  }
}

fn main() {
  let s = Schema.string().min(3).max(10)
  report("short", s.validate("hi"))
  report("valid", s.validate("hello"))
  report("long", s.validate("waytoolongvalue"))

  let em = Schema.string().email()
  report("email ok", em.validate("a@b.com"))
  report("email bad", em.validate("bad"))

  let url = Schema.string().url()
  report("url ok", url.validate("https://x.com"))
  report("url bad", url.validate("ftp://x"))

  // required embutido em Schema.string(): string vazia falha
  report("empty", Schema.string().validate(""))
}
