// Regressão de runtime: iter
// Exercita: chunk, window, zip, enumerate, flatten, flatMap, compact,
//           distinct, partition, groupBy, scan, take, skip, takeWhile,
//           skipWhile, sortBy, find, any, all, count
import { chunk, window, zip, enumerate, flatten, flatMap, distinct, partition, groupBy, scan, take, skip, takeWhile, skipWhile, sortBy, any, all, count } from "iter"

fn main() {
  let nums = [1, 2, 3, 4, 5]
  println("chunk = " + chunk(nums, 2).toString())
  println("window = " + window(nums, 3).toString())
  println("zip = " + zip([1, 2, 3], ["a", "b", "c"]).toString())
  println("enumerate = " + enumerate(["a", "b"]).toString())
  println("flatten = " + flatten([[1, 2], [3], [4, 5]]).toString())
  println("flatMap = " + flatMap([1, 2, 3], (x) => [x, x * 10]).toString())
  println("distinct = " + distinct([1, 1, 2, 3, 3, 3]).toString())
  println("partition = " + partition(nums, (x) => x % 2 == 0).toString())
  println("groupBy = " + groupBy(nums, (x) => x % 2).toString())
  println("scan = " + scan(nums, 0, (acc, x) => acc + x).toString())
  println("take = " + take(nums, 2).toString())
  println("skip = " + skip(nums, 2).toString())
  println("takeWhile = " + takeWhile(nums, (x) => x < 3).toString())
  println("skipWhile = " + skipWhile(nums, (x) => x < 3).toString())
  println("sortBy = " + sortBy([3, 1, 2], (x) => x).toString())
  println("any = " + any(nums, (x) => x > 4).toString())
  println("all = " + all(nums, (x) => x > 0).toString())
  println("count = " + count(nums, (x) => x % 2 == 0).toString())
}
