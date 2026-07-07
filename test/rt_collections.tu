// Regressão de runtime: collections
// Exercita: Stack (push/pop/peek/size), Queue (enqueue/dequeue),
//           Deque (pushFront/pushBack/popFront/popBack),
//           mergeSort/quickSort/heapSort/insertionSort/timSort/radixSort,
//           Graph (bfs/dfs), DiGraph (topologicalSort)
// NOTA: PriorityQueue.insert está omitido de propósito — a impl atual chama
// `List.set` que o codegen ainda não suporta (NoSuchMethodError em runtime).
// Registrado como bug da stdlib/compilador; reintroduzir quando corrigido.
import { Stack, Queue, Deque, mergeSort, quickSort, heapSort, insertionSort, timSort, radixSort, Graph, DiGraph } from "collections"

fn main() {
  var s = Stack.new()
  s = s.push(1)
  s = s.push(2)
  s = s.push(3)
  println("stack size = " + s.size().toString())
  match s.peek() {
    .some(top) => println("stack peek = " + top.toString()),
    .none => println("empty")
  }
  match s.pop() {
    .some(pair) => println("stack pop top = " + pair.0.toString()),
    .none => println("empty")
  }

  var q = Queue.new()
  q = q.enqueue("a")
  q = q.enqueue("b")
  match q.dequeue() {
    .some(pair) => println("queue front = " + pair.0),
    .none => println("empty")
  }

  var dq = Deque.new()
  dq = dq.pushBack(1)
  dq = dq.pushBack(2)
  dq = dq.pushFront(0)
  match dq.popFront() {
    .some(pair) => println("deque popFront = " + pair.0.toString()),
    .none => println("empty")
  }
  match dq.popBack() {
    .some(pair) => println("deque popBack = " + pair.0.toString()),
    .none => println("empty")
  }

  let data = [5, 3, 8, 1, 9, 2]
  println("mergeSort = " + mergeSort(data, (a, b) => a - b).toString())
  println("quickSort = " + quickSort(data, (a, b) => a - b).toString())
  println("heapSort = " + heapSort(data, (a, b) => a - b).toString())
  println("insertionSort = " + insertionSort(data, (a, b) => a - b).toString())
  println("timSort = " + timSort(data, (a, b) => a - b).toString())
  println("radixSort = " + radixSort(data).toString())

  var g = Graph.new()
  g = g.addNode("A")
  g = g.addNode("B")
  g = g.addNode("C")
  g = g.addNode("D")
  g = g.addEdge(0, 1)
  g = g.addEdge(0, 2)
  g = g.addEdge(1, 3)
  println("bfs = " + g.bfs(0).toString())
  println("dfs = " + g.dfs(0).toString())

  var dg = DiGraph.new()
  dg = dg.addNode("a")
  dg = dg.addNode("b")
  dg = dg.addNode("c")
  dg = dg.addEdge(0, 1)
  dg = dg.addEdge(1, 2)
  match dg.topologicalSort() {
    .some(order) => println("topo = " + order.toString()),
    .none => println("cycle")
  }
}
