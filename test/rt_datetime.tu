// Regressão de runtime: datetime
// Exercita: DateTime.date, format, isLeapYear, addDays, dayOfWeek, dayOfYear,
//           diffInDays/Hours, isBefore/isAfter, startOf/endOf, toIso.
//           Usa datas FIXAS → sem relógio real, determinístico.
import { DateTime } from "datetime"

fn main() {
  let d = DateTime.date(2024, 2, 29)
  println("format = " + d.format("yyyy-MM-dd"))
  println("isLeapYear(2024) = " + d.isLeapYear().toString())
  println("isLeapYear(2023) = " + DateTime.date(2023, 1, 1).isLeapYear().toString())
  let d2 = d.addDays(1)
  println("addDays = " + d2.format("yyyy-MM-dd"))
  println("dayOfWeek = " + d.dayOfWeek().toString())
  println("dayOfYear = " + d.dayOfYear().toString())
  println("toIso = " + d.toIso())

  let a = DateTime.date(2024, 1, 1)
  let b = DateTime.date(2024, 1, 11)
  println("diffInDays = " + b.diffInDays(a).toString())
  println("diffInHours = " + b.diffInHours(a).toString())
  println("isBefore = " + a.isBefore(b).toString())
  println("isAfter = " + a.isAfter(b).toString())

  let m = DateTime.date(2024, 2, 15)
  println("startOfMonth = " + m.startOfMonth().format("yyyy-MM-dd"))
  println("endOfMonth = " + m.endOfMonth().format("yyyy-MM-dd"))
  println("startOfYear = " + m.startOfYear().format("yyyy-MM-dd"))
  println("endOfYear = " + m.endOfYear().format("yyyy-MM-dd"))
}
