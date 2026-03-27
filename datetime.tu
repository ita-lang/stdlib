// Foundation: DateTime
// Extensões sobre Date/Duration nativos

struct DateTime {
  year: Int
  month: Int
  day: Int
  hour: Int
  minute: Int
  second: Int
  ms: Int

  fn now() -> DateTime {
    let d = Date.now()
    return DateTime {
      year: d.year, month: d.month, day: d.day,
      hour: d.hour, minute: d.minute, second: d.second, ms: d.millisecond
    }
  }

  fn date(year: Int, month: Int, day: Int) -> DateTime {
    return DateTime {
      year: year, month: month, day: day,
      hour: 0, minute: 0, second: 0, ms: 0
    }
  }

  fn today() -> DateTime => DateTime.now().startOfDay()
  fn tomorrow() -> DateTime => DateTime.today().addDays(1)
  fn yesterday() -> DateTime => DateTime.today().addDays(-1)

  // === Arithmetic ===

  fn addDays(self, n: Int) -> DateTime {
    var d = self.day + n
    var m = self.month
    var y = self.year
    while d > _daysInMonth(m, y) {
      d -= _daysInMonth(m, y)
      m += 1
      if m > 12 { m = 1; y += 1 }
    }
    while d < 1 {
      m -= 1
      if m < 1 { m = 12; y -= 1 }
      d += _daysInMonth(m, y)
    }
    return self.{ year: y, month: m, day: d }
  }

  fn addHours(self, n: Int) -> DateTime {
    let totalMinutes = self.toMinutes() + n * 60
    return DateTime.fromMinutes(totalMinutes)
  }

  fn addMinutes(self, n: Int) -> DateTime {
    let totalMinutes = self.toMinutes() + n
    return DateTime.fromMinutes(totalMinutes)
  }

  fn addSeconds(self, n: Int) -> DateTime {
    let totalSec = self.toSeconds() + n
    return DateTime.fromSeconds(totalSec)
  }

  // === Comparison ===

  fn isBefore(self, other: DateTime) -> Bool {
    return self.toSeconds() < other.toSeconds()
  }

  fn isAfter(self, other: DateTime) -> Bool {
    return self.toSeconds() > other.toSeconds()
  }

  fn isBetween(self, start: DateTime, end: DateTime) -> Bool {
    let s = self.toSeconds()
    return s >= start.toSeconds() && s <= end.toSeconds()
  }

  fn isEqual(self, other: DateTime) -> Bool {
    return self.toSeconds() == other.toSeconds()
  }

  // === Diff ===

  fn diffInDays(self, other: DateTime) -> Int {
    return (self.toSeconds() - other.toSeconds()) / 86400
  }

  fn diffInHours(self, other: DateTime) -> Int {
    return (self.toSeconds() - other.toSeconds()) / 3600
  }

  fn diffInMinutes(self, other: DateTime) -> Int {
    return (self.toSeconds() - other.toSeconds()) / 60
  }

  fn diffInSeconds(self, other: DateTime) -> Int {
    return self.toSeconds() - other.toSeconds()
  }

  // === Boundaries ===

  fn startOfDay(self) -> DateTime {
    return self.{ hour: 0, minute: 0, second: 0, ms: 0 }
  }

  fn endOfDay(self) -> DateTime {
    return self.{ hour: 23, minute: 59, second: 59, ms: 999 }
  }

  fn startOfMonth(self) -> DateTime {
    return self.{ day: 1, hour: 0, minute: 0, second: 0, ms: 0 }
  }

  fn endOfMonth(self) -> DateTime {
    let lastDay = _daysInMonth(self.month, self.year)
    return self.{ day: lastDay, hour: 23, minute: 59, second: 59, ms: 999 }
  }

  fn startOfYear(self) -> DateTime {
    return self.{ month: 1, day: 1, hour: 0, minute: 0, second: 0, ms: 0 }
  }

  fn endOfYear(self) -> DateTime {
    return self.{ month: 12, day: 31, hour: 23, minute: 59, second: 59, ms: 999 }
  }

  // === Formatting ===

  fn format(self, pattern: String) -> String {
    var result = pattern
    result = result.replaceAll("yyyy", _padInt(self.year, 4))
    result = result.replaceAll("MM", _padInt(self.month, 2))
    result = result.replaceAll("dd", _padInt(self.day, 2))
    result = result.replaceAll("HH", _padInt(self.hour, 2))
    result = result.replaceAll("mm", _padInt(self.minute, 2))
    result = result.replaceAll("ss", _padInt(self.second, 2))
    return result
  }

  fn toIso(self) -> String {
    return self.format("yyyy-MM-ddTHH:mm:ss")
  }

  fn relative(self, now: DateTime) -> String {
    let diffSec = now.toSeconds() - self.toSeconds()
    let absDiff = if diffSec < 0 { -diffSec } else { diffSec }
    let future = diffSec < 0

    if absDiff < 60 { return if future { "in a few seconds" } else { "just now" } }
    if absDiff < 3600 {
      let mins = absDiff / 60
      return if future { "in ${mins} minutes" } else { "${mins} minutes ago" }
    }
    if absDiff < 86400 {
      let hours = absDiff / 3600
      return if future { "in ${hours} hours" } else { "${hours} hours ago" }
    }
    let days = absDiff / 86400
    if days == 1 { return if future { "tomorrow" } else { "yesterday" } }
    if days < 30 { return if future { "in ${days} days" } else { "${days} days ago" } }
    let months = days / 30
    if months < 12 { return if future { "in ${months} months" } else { "${months} months ago" } }
    let years = days / 365
    return if future { "in ${years} years" } else { "${years} years ago" }
  }

  // === Properties ===

  fn dayOfWeek(self) -> Int {
    // Zeller's formula (0=Sunday, 6=Saturday)
    var m = self.month
    var y = self.year
    if m < 3 { m += 12; y -= 1 }
    let k = y % 100
    let j = y / 100
    let h = (self.day + (13 * (m + 1)) / 5 + k + k / 4 + j / 4 - 2 * j) % 7
    return ((h + 6) % 7)  // 0=Monday, 6=Sunday
  }

  fn dayOfYear(self) -> Int {
    let daysPerMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    var total = self.day
    var i = 0
    while i < self.month - 1 {
      total += daysPerMonth[i]
      if i == 1 && _isLeapYear(self.year) { total += 1 }
      i += 1
    }
    return total
  }

  fn isLeapYear(self) -> Bool => _isLeapYear(self.year)

  fn isWeekend(self) -> Bool {
    let dow = self.dayOfWeek()
    return dow == 5 || dow == 6  // Saturday or Sunday
  }

  // === Internal ===

  fn toSeconds(self) -> Int {
    // Simplified: days since epoch approximation
    var totalDays = 0
    var y = 1970
    while y < self.year {
      totalDays += if _isLeapYear(y) { 366 } else { 365 }
      y += 1
    }
    totalDays += self.dayOfYear() - 1
    return totalDays * 86400 + self.hour * 3600 + self.minute * 60 + self.second
  }

  fn toMinutes(self) -> Int => self.toSeconds() / 60

  fn fromMinutes(totalMin: Int) -> DateTime {
    return DateTime.fromSeconds(totalMin * 60)
  }

  fn fromSeconds(totalSec: Int) -> DateTime {
    var remaining = totalSec
    var year = 1970
    while true {
      let daysInYear = if _isLeapYear(year) { 366 } else { 365 }
      if remaining < daysInYear * 86400 {
        let dayOfYear = remaining / 86400
        remaining = remaining % 86400
        let hour = remaining / 3600
        remaining = remaining % 3600
        let minute = remaining / 60
        let second = remaining % 60

        var month = 1
        var day = dayOfYear + 1
        let daysPerMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        while month <= 12 {
          let dim = if month == 2 && _isLeapYear(year) { 29 } else { daysPerMonth[month - 1] }
          if day <= dim {
            return DateTime { year: year, month: month, day: day, hour: hour, minute: minute, second: second, ms: 0 }
          }
          day -= dim
          month += 1
        }
        return DateTime { year: year, month: 12, day: 31, hour: hour, minute: minute, second: second, ms: 0 }
      }
      remaining -= daysInYear * 86400
      year += 1
    }
    return DateTime.date(1970, 1, 1)
  }
}

// === Private helpers ===

fn _isLeapYear(year: Int) -> Bool {
  return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
}

fn _daysInMonth(month: Int, year: Int) -> Int {
  let days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  if month == 2 && _isLeapYear(year) { return 29 }
  return days[month - 1]
}

fn _padInt(n: Int, width: Int) -> String {
  var s = "${n}"
  while s.length < width {
    s = "0" + s
  }
  return s
}
