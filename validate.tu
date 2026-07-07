// Foundation: Validate
// Schema builder declarativo → Result<T, List<String>>

enum SchemaRule {
  required,
  minLen(value: Int),
  maxLen(value: Int),
  minVal(value: Int),
  maxVal(value: Int),
  pattern(value: String),
  email,
  url,
  oneOf(values: List<String>),
  custom(pred: (String) -> Bool, msg: String)
}

struct Schema {
  rules: List<SchemaRule>
}

extension Schema {
  static fn string() -> Schema => Schema(rules: [.required])
  static fn int() -> Schema => Schema(rules: [.required])
  static fn optional() -> Schema => Schema(rules: [])

  fn required() -> Schema {
    return Schema(rules: self.rules + [.required])
  }

  fn min(n: Int) -> Schema {
    return Schema(rules: self.rules + [.minLen(n)])
  }

  fn max(n: Int) -> Schema {
    return Schema(rules: self.rules + [.maxLen(n)])
  }

  fn minVal(n: Int) -> Schema {
    return Schema(rules: self.rules + [.minVal(n)])
  }

  fn maxVal(n: Int) -> Schema {
    return Schema(rules: self.rules + [.maxVal(n)])
  }

  fn email() -> Schema {
    return Schema(rules: self.rules + [.email])
  }

  fn url() -> Schema {
    return Schema(rules: self.rules + [.url])
  }

  fn oneOf(values: List<String>) -> Schema {
    return Schema(rules: self.rules + [.oneOf(values)])
  }

  fn matches(pattern: String) -> Schema {
    return Schema(rules: self.rules + [.pattern(pattern)])
  }

  fn check(pred: (String) -> Bool, msg: String) -> Schema {
    return Schema(rules: self.rules + [.custom(pred, msg)])
  }

  fn validate(value: String) -> Result<String, List<String>> {
    var errors: List<String> = []

    for rule in self.rules {
      errors = errors + _ruleErrors(rule, value)
    }

    if errors.length > 0 { return .err(errors) }
    return .ok(value)
  }
}

// === Rule evaluation ===

fn _ruleErrors(rule: SchemaRule, value: String) -> List<String> {
  match rule {
    .required => if value.length == 0 { ["field is required"] } else { [] },
    .minLen(n) => if value.length < n { ["must be at least ${n} characters"] } else { [] },
    .maxLen(n) => if value.length > n { ["must be at most ${n} characters"] } else { [] },
    // Assume numeric string. toInt() -> Int? (null se não-parseável); default 0
    // via ?? antes de comparar (?? tem precedência menor que <, então parênteses).
    .minVal(n) => if (value.toInt() ?? 0) < n { ["must be at least ${n}"] } else { [] },
    .maxVal(n) => if (value.toInt() ?? 0) > n { ["must be at most ${n}"] } else { [] },
    .email => _checkEmail(value),
    .url => if !value.startsWith("http://") && !value.startsWith("https://") { ["must be a valid URL"] } else { [] },
    .oneOf(values) => _checkOneOf(value, values),
    // Basic pattern check — delegates to runtime
    .pattern(p) => if !value.matches(p) { ["must match pattern ${p}"] } else { [] },
    .custom(pred, msg) => if !pred(value) { [msg] } else { [] }
  }
}

fn _checkEmail(value: String) -> List<String> {
  let parts = value.split("@")
  if parts.length != 2 || parts[1].indexOf(".") < 0 {
    return ["must be a valid email"]
  }
  return []
}

fn _checkOneOf(value: String, values: List<String>) -> List<String> {
  var found = false
  for v in values {
    if v == value { found = true }
  }
  if !found { return ["must be one of: ${values.join(", ")}"] }
  return []
}

// === Object Schema ===

struct FieldSchema {
  name: String
  schema: Schema
}

struct ObjectSchema {
  fields: List<FieldSchema>
}

extension ObjectSchema {
  static fn new() -> ObjectSchema => ObjectSchema(fields: [])

  fn field(name: String, schema: Schema) -> ObjectSchema {
    return ObjectSchema(fields: self.fields + [FieldSchema(name: name, schema: schema)])
  }

  fn validate(data: Map<String, String>) -> Result<Map<String, String>, List<String>> {
    var allErrors: List<String> = []

    for f in self.fields {
      let value = data.get(f.name) ?? ""
      let fieldErrors = match f.schema.validate(value) {
        .ok(_) => [],
        .err(errors) => _prefixErrors(f.name, errors)
      }
      allErrors = allErrors + fieldErrors
    }

    if allErrors.length > 0 { return .err(allErrors) }
    return .ok(data)
  }
}

fn _prefixErrors(name: String, errors: List<String>) -> List<String> {
  var result: List<String> = []
  for e in errors {
    result = result + ["${name}: ${e}"]
  }
  return result
}
