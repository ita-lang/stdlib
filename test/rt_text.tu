// Regressão de runtime: text
// Exercita: camelCase, snakeCase, pascalCase, kebabCase, slugify, capitalize,
//           trim, padStart, padEnd, repeat, reverse, toLower, toUpper,
//           isEmail, isUrl, isNumeric, isAlpha, contains, countOccurrences,
//           startsWith, endsWith, template
import { camelCase, snakeCase, pascalCase, kebabCase, slugify, capitalize, trim, padStart, padEnd, repeat, reverse, toLower, toUpper, isEmail, isUrl, isNumeric, isAlpha, contains, countOccurrences, startsWith, endsWith, template } from "text"

fn main() {
  println("camelCase = " + camelCase("hello world foo"))
  println("snakeCase = " + snakeCase("Hello World"))
  println("pascalCase = " + pascalCase("hello world"))
  println("kebabCase = " + kebabCase("Hello World"))
  println("slugify = " + slugify("Hello, World!"))
  println("capitalize = " + capitalize("itaLang"))
  println("trim = '" + trim("  hi  ") + "'")
  println("padStart = " + padStart("5", 3, "0"))
  println("padEnd = " + padEnd("5", 3, "0"))
  println("repeat = " + repeat("ab", 3))
  println("reverse = " + reverse("abc"))
  println("toLower = " + toLower("ABC"))
  println("toUpper = " + toUpper("abc"))
  println("isEmail(ok) = " + isEmail("a@b.com").toString())
  println("isEmail(bad) = " + isEmail("bad").toString())
  println("isUrl = " + isUrl("https://x.com").toString())
  println("isNumeric(123) = " + isNumeric("123").toString())
  println("isNumeric(12a) = " + isNumeric("12a").toString())
  println("isAlpha(abc) = " + isAlpha("abc").toString())
  println("contains = " + contains("hello", "ell").toString())
  println("countOccurrences = " + countOccurrences("banana", "a").toString())
  println("startsWith = " + startsWith("file.tu", "file").toString())
  println("endsWith = " + endsWith("file.tu", ".tu").toString())
  let ctx: Map<String, String> = { "name": "World" }
  println("template = " + template("Hello {name}", ctx))
}
