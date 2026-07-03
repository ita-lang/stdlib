// Foundation: Text
// Utilitários de string para Itá

// === Case Conversion ===

fn camelCase(s: String) -> String {
  let words = splitWords(s)
  if words.length == 0 { return "" }
  var result = toLower(words[0])
  var i = 1
  while i < words.length {
    result = result + capitalize(words[i])
    i += 1
  }
  return result
}

fn pascalCase(s: String) -> String {
  let words = splitWords(s)
  var result = ""
  for word in words {
    result = result + capitalize(word)
  }
  return result
}

fn snakeCase(s: String) -> String {
  let words = splitWords(s)
  var result = ""
  var i = 0
  for word in words {
    if i > 0 { result = result + "_" }
    result = result + toLower(word)
    i += 1
  }
  return result
}

fn kebabCase(s: String) -> String {
  let words = splitWords(s)
  var result = ""
  var i = 0
  for word in words {
    if i > 0 { result = result + "-" }
    result = result + toLower(word)
    i += 1
  }
  return result
}

fn screamingSnakeCase(s: String) -> String {
  let words = splitWords(s)
  var result = ""
  var i = 0
  for word in words {
    if i > 0 { result = result + "_" }
    result = result + toUpper(word)
    i += 1
  }
  return result
}

// === String Helpers ===

fn capitalize(s: String) -> String {
  if s.length == 0 { return s }
  return toUpper(s[0]) + s.substring(1)
}

fn toLower(s: String) -> String {
  var result = ""
  for ch in s {
    let code = ch.codeUnit
    if code >= 65 && code <= 90 {
      result = result + String.fromCodeUnit(code + 32)
    } else {
      result = result + ch
    }
  }
  return result
}

fn toUpper(s: String) -> String {
  var result = ""
  for ch in s {
    let code = ch.codeUnit
    if code >= 97 && code <= 122 {
      result = result + String.fromCodeUnit(code - 32)
    } else {
      result = result + ch
    }
  }
  return result
}

// === Padding & Trimming ===

fn padStart(s: String, length: Int, fill: String) -> String {
  if s.length >= length { return s }
  var pad = ""
  while pad.length + s.length < length {
    pad = pad + fill
  }
  return pad.substring(0, length - s.length) + s
}

fn padEnd(s: String, length: Int, fill: String) -> String {
  if s.length >= length { return s }
  var pad = ""
  while s.length + pad.length < length {
    pad = pad + fill
  }
  return s + pad.substring(0, length - s.length)
}

fn trim(s: String) -> String {
  var start = 0
  var end = s.length - 1
  while start <= end && isWhitespace(s[start]) {
    start += 1
  }
  while end >= start && isWhitespace(s[end]) {
    end -= 1
  }
  return s.substring(start, end + 1)
}

fn trimStart(s: String) -> String {
  var start = 0
  while start < s.length && isWhitespace(s[start]) {
    start += 1
  }
  return s.substring(start)
}

fn trimEnd(s: String) -> String {
  var end = s.length - 1
  while end >= 0 && isWhitespace(s[end]) {
    end -= 1
  }
  return s.substring(0, end + 1)
}

// === Manipulation ===

fn repeat(s: String, times: Int) -> String {
  var result = ""
  var i = 0
  while i < times {
    result = result + s
    i += 1
  }
  return result
}

fn reverse(s: String) -> String {
  var result = ""
  var i = s.length - 1
  while i >= 0 {
    result = result + s[i]
    i -= 1
  }
  return result
}

fn truncate(s: String, maxLen: Int, suffix: String) -> String {
  if s.length <= maxLen { return s }
  return s.substring(0, maxLen - suffix.length) + suffix
}

fn slugify(s: String) -> String {
  var result = ""
  for ch in toLower(s) {
    let code = ch.codeUnit
    if (code >= 97 && code <= 122) || (code >= 48 && code <= 57) {
      result = result + ch
    } else if ch == " " || ch == "_" || ch == "-" {
      if result.length > 0 && result[result.length - 1] != "-" {
        result = result + "-"
      }
    }
  }
  // Remove trailing dash
  if result.length > 0 && result[result.length - 1] == "-" {
    result = result.substring(0, result.length - 1)
  }
  return result
}

fn wordWrap(s: String, width: Int) -> String {
  let words = s.split(" ")
  var lines: List<String> = []
  var currentLine = ""
  for word in words {
    if currentLine.length == 0 {
      currentLine = word
    } else if currentLine.length + 1 + word.length <= width {
      currentLine = currentLine + " " + word
    } else {
      lines = lines + [currentLine]
      currentLine = word
    }
  }
  if currentLine.length > 0 {
    lines = lines + [currentLine]
  }
  return lines.join("\n")
}

// === Validation ===

fn isBlank(s: String) -> Bool {
  for ch in s {
    if !isWhitespace(ch) { return false }
  }
  return true
}

fn isNumeric(s: String) -> Bool {
  if s.length == 0 { return false }
  for ch in s {
    let code = ch.codeUnit
    if code < 48 || code > 57 { return false }
  }
  return true
}

fn isAlpha(s: String) -> Bool {
  if s.length == 0 { return false }
  for ch in s {
    let code = ch.codeUnit
    let isLower = code >= 97 && code <= 122
    let isUpper = code >= 65 && code <= 90
    if !isLower && !isUpper { return false }
  }
  return true
}

fn isAlphaNumeric(s: String) -> Bool {
  if s.length == 0 { return false }
  for ch in s {
    let code = ch.codeUnit
    let isLower = code >= 97 && code <= 122
    let isUpper = code >= 65 && code <= 90
    let isDigit = code >= 48 && code <= 57
    if !isLower && !isUpper && !isDigit { return false }
  }
  return true
}

fn isEmail(s: String) -> Bool {
  let parts = s.split("@")
  if parts.length != 2 { return false }
  let local = parts[0]
  let domain = parts[1]
  if local.length == 0 { return false }
  if domain.length == 0 { return false }
  let domainParts = domain.split(".")
  if domainParts.length < 2 { return false }
  let tld = domainParts[domainParts.length - 1]
  if tld.length < 2 { return false }
  return true
}

fn isUrl(s: String) -> Bool {
  return s.startsWith("http://") || s.startsWith("https://")
}

// === Template ===

fn template(tmpl: String, context: Map<String, String>) -> String {
  var result = tmpl
  for key in context.keys() {
    result = result.replaceAll("{${key}}", context[key])
  }
  return result
}

// === Internal Helpers ===

fn isWhitespace(ch: String) -> Bool {
  return ch == " " || ch == "\t" || ch == "\n" || ch == "\r"
}

fn isUpperCase(ch: String) -> Bool {
  let code = ch.codeUnit
  return code >= 65 && code <= 90
}

fn splitWords(s: String) -> List<String> {
  var words: List<String> = []
  var current = ""
  for ch in s {
    let code = ch.codeUnit
    if ch == " " || ch == "_" || ch == "-" || ch == "." {
      if current.length > 0 {
        words = words + [current]
        current = ""
      }
    } else if isUpperCase(ch) && current.length > 0 {
      words = words + [current]
      current = ch
    } else {
      current = current + ch
    }
  }
  if current.length > 0 {
    words = words + [current]
  }
  return words
}

// === Search & Count ===

fn contains(s: String, sub: String) -> Bool => s.indexOf(sub) >= 0

fn countOccurrences(s: String, sub: String) -> Int {
  var count = 0
  var pos = 0
  while pos < s.length {
    let idx = s.indexOf(sub, pos)
    if idx < 0 { return count }
    count += 1
    pos = idx + sub.length
  }
  return count
}

fn startsWith(s: String, prefix: String) -> Bool {
  if prefix.length > s.length { return false }
  return s.substring(0, prefix.length) == prefix
}

fn endsWith(s: String, suffix: String) -> Bool {
  if suffix.length > s.length { return false }
  return s.substring(s.length - suffix.length) == suffix
}
