// Foundation: Validate
// Schema builder declarativo → Result<T, List<String>>

enum SchemaRule {
  required,
  minLen(Int),
  maxLen(Int),
  minVal(Int),
  maxVal(Int),
  pattern(String),
  email,
  url,
  oneOf(List<String>),
  custom((String) -> Bool, String)
}

struct Schema {
  rules: List<SchemaRule>

  fn string() -> Schema => Schema { rules: [.required] }
  fn int() -> Schema => Schema { rules: [.required] }
  fn optional() -> Schema => Schema { rules: [] }

  fn required(self) -> Schema {
    return Schema { rules: self.rules + [.required] }
  }

  fn min(self, n: Int) -> Schema {
    return Schema { rules: self.rules + [.minLen(n)] }
  }

  fn max(self, n: Int) -> Schema {
    return Schema { rules: self.rules + [.maxLen(n)] }
  }

  fn minVal(self, n: Int) -> Schema {
    return Schema { rules: self.rules + [.minVal(n)] }
  }

  fn maxVal(self, n: Int) -> Schema {
    return Schema { rules: self.rules + [.maxVal(n)] }
  }

  fn email(self) -> Schema {
    return Schema { rules: self.rules + [.email] }
  }

  fn url(self) -> Schema {
    return Schema { rules: self.rules + [.url] }
  }

  fn oneOf(self, values: List<String>) -> Schema {
    return Schema { rules: self.rules + [.oneOf(values)] }
  }

  fn matches(self, pattern: String) -> Schema {
    return Schema { rules: self.rules + [.pattern(pattern)] }
  }

  fn check(self, pred: (String) -> Bool, msg: String) -> Schema {
    return Schema { rules: self.rules + [.custom(pred, msg)] }
  }

  fn validate(self, value: String) -> Result<String, List<String>> {
    var errors: List<String> = []

    for rule in self.rules {
      match rule {
        .required => {
          if value.length == 0 { errors = errors + ["field is required"] }
        },
        .minLen(n) => {
          if value.length < n { errors = errors + ["must be at least ${n} characters"] }
        },
        .maxLen(n) => {
          if value.length > n { errors = errors + ["must be at most ${n} characters"] }
        },
        .minVal(n) => {
          // Assume numeric string
          if value.toInt() < n { errors = errors + ["must be at least ${n}"] }
        },
        .maxVal(n) => {
          if value.toInt() > n { errors = errors + ["must be at most ${n}"] }
        },
        .email => {
          let parts = value.split("@")
          if parts.length != 2 || parts[1].indexOf(".") < 0 {
            errors = errors + ["must be a valid email"]
          }
        },
        .url => {
          if !value.startsWith("http://") && !value.startsWith("https://") {
            errors = errors + ["must be a valid URL"]
          }
        },
        .oneOf(values) => {
          var found = false
          for v in values {
            if v == value { found = true }
          }
          if !found { errors = errors + ["must be one of: ${values.join(", ")}"] }
        },
        .pattern(p) => {
          // Basic pattern check — delegates to runtime
          if !value.matches(p) { errors = errors + ["must match pattern ${p}"] }
        },
        .custom(pred, msg) => {
          if !pred(value) { errors = errors + [msg] }
        }
      }
    }

    if errors.length > 0 { return .err(errors) }
    return .ok(value)
  }
}

// === Object Schema ===

struct FieldSchema {
  name: String
  schema: Schema
}

struct ObjectSchema {
  fields: List<FieldSchema>

  fn new() -> ObjectSchema => ObjectSchema { fields: [] }

  fn field(self, name: String, schema: Schema) -> ObjectSchema {
    return ObjectSchema { fields: self.fields + [FieldSchema { name: name, schema: schema }] }
  }

  fn validate(self, data: Map<String, String>) -> Result<Map<String, String>, List<String>> {
    var allErrors: List<String> = []

    for f in self.fields {
      let value = data.get(f.name) ?? ""
      match f.schema.validate(value) {
        .ok(_) => {},
        .err(errors) => {
          for e in errors {
            allErrors = allErrors + ["${f.name}: ${e}"]
          }
        }
      }
    }

    if allErrors.length > 0 { return .err(allErrors) }
    return .ok(data)
  }
}
