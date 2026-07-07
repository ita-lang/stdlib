// Foundation: Collections
// Estruturas de dados, grafos e algoritmos de sorting.
//
// MODELO DUAL: safe (imutavel) + unsafe (mutavel)
//
// Cada estrutura tem duas versoes:
//   Stack<T>     — imutavel, retorna nova instancia a cada operacao
//   MutStack<T>  — mutavel, modifica in-place (marcada como unsafe)
//
// QUANDO USAR CADA:
//   safe  → estado compartilhado, concorrencia, debug, previsibilidade
//   unsafe → hot loops, batch processing, performance critica
//
// TRADEOFFS:
//   safe  → push O(n) por copia, mas sem race conditions, sem side effects
//   unsafe → push O(1) amortizado, mas mutacao visivel, cuidado em concorrencia

// ============================================================
// Stack<T> — LIFO (safe, imutavel)
// ============================================================
// Cada operacao retorna nova instancia. A original nao muda.
// Ideal para: estado em closures, recursao, debug.
//
// Complexidade (custo da imutabilidade):
//   push: O(n) — copia a lista interna
//   pop:  O(n) — copia a lista interna
//   peek: O(1) — acesso direto ao ultimo elemento

pub struct Stack<T> {
  items: List<T>
}

extension Stack {
  static fn new() -> Stack<T> => Stack(items: [])

  // O(n) — cria nova lista com o elemento adicionado ao final
  pub fn push(value: T) -> Stack<T> {
    return Stack(items: self.items + [value])
  }

  // O(n) — cria nova lista sem o ultimo elemento
  pub fn pop() -> Option<(T, Stack<T>)> {
    if self.items.length == 0 { return .none }
    let top = self.items[self.items.length - 1]
    let rest = self.items.slice(0, self.items.length - 1)
    return .some((top, Stack(items: rest)))
  }

  // O(1) — acesso direto
  pub fn peek() -> Option<T> {
    if self.items.length == 0 { return .none }
    return .some(self.items[self.items.length - 1])
  }

  pub fn isEmpty() -> Bool => self.items.length == 0
  pub fn size() -> Int => self.items.length
  pub fn toList() -> List<T> => self.items
}

// ============================================================
// MutStack<T> — LIFO (unsafe, mutavel)
// ============================================================
// Modifica a lista in-place. Mais rapido, mas cuidado com
// aliasing — se duas variaveis apontam para o mesmo MutStack,
// ambas veem a mutacao.
//
// Complexidade:
//   push: O(1) amortizado — append in-place
//   pop:  O(1) — remove ultimo in-place
//   peek: O(1) — acesso direto
//
// Usar quando: batch processing, hot loops, algoritmos internos
// NAO usar quando: estado compartilhado entre isolates/actors

pub struct MutStack<T> {
  var items: List<T>
}

extension MutStack {
  static fn new() -> MutStack<T> => MutStack(items: [])

  // O(1) amortizado — modifica in-place
  pub fn push(value: T) {
    self.items = self.items + [value]
  }

  // O(1) — remove ultimo in-place
  pub fn pop() -> Option<T> {
    if self.items.length == 0 { return .none }
    let top = self.items[self.items.length - 1]
    self.items = self.items.slice(0, self.items.length - 1)
    return .some(top)
  }

  // O(1)
  pub fn peek() -> Option<T> {
    if self.items.length == 0 { return .none }
    return .some(self.items[self.items.length - 1])
  }

  pub fn isEmpty() -> Bool => self.items.length == 0
  pub fn size() -> Int => self.items.length
  pub fn toList() -> List<T> => self.items
}

// ============================================================
// Queue<T> — FIFO (safe, imutavel)
// ============================================================
// Complexidade (custo da imutabilidade):
//   enqueue: O(n) — copia a lista
//   dequeue: O(n) — copia a lista
//   peek:    O(1) — acesso direto

pub struct Queue<T> {
  items: List<T>
}

extension Queue {
  static fn new() -> Queue<T> => Queue(items: [])

  // O(n) — cria nova lista com elemento no final
  pub fn enqueue(value: T) -> Queue<T> {
    return Queue(items: self.items + [value])
  }

  // O(n) — cria nova lista sem o primeiro
  pub fn dequeue() -> Option<(T, Queue<T>)> {
    if self.items.length == 0 { return .none }
    let front = self.items[0]
    let rest = self.items.slice(1)
    return .some((front, Queue(items: rest)))
  }

  // O(1)
  pub fn peek() -> Option<T> {
    if self.items.length == 0 { return .none }
    return .some(self.items[0])
  }

  pub fn isEmpty() -> Bool => self.items.length == 0
  pub fn size() -> Int => self.items.length
  pub fn toList() -> List<T> => self.items
}

// ============================================================
// MutQueue<T> — FIFO (unsafe, mutavel)
// ============================================================
// Usa duas listas internas (inbox + outbox) para dequeue O(1) amortizado.
// Tecnica classica de functional queue adaptada para mutacao.
//
// Complexidade:
//   enqueue: O(1) amortizado
//   dequeue: O(1) amortizado (O(n) quando precisa reverter inbox → outbox)
//   peek:    O(1) amortizado

pub struct MutQueue<T> {
  var inbox: List<T>
  var outbox: List<T>
}

extension MutQueue {
  static fn new() -> MutQueue<T> => MutQueue(inbox: [], outbox: [])

  // O(1) amortizado
  pub fn enqueue(value: T) {
    self.inbox = self.inbox + [value]
  }

  // O(1) amortizado — O(n) quando outbox vazia (reverte inbox)
  pub fn dequeue() -> Option<T> {
    if self.outbox.length == 0 {
      if self.inbox.length == 0 { return .none }
      // Reverter inbox para outbox
      var i = self.inbox.length - 1
      while i >= 0 {
        self.outbox = self.outbox + [self.inbox[i]]
        i -= 1
      }
      self.inbox = []
    }
    let front = self.outbox[self.outbox.length - 1]
    self.outbox = self.outbox.slice(0, self.outbox.length - 1)
    return .some(front)
  }

  pub fn isEmpty() -> Bool => self.inbox.length == 0 && self.outbox.length == 0
  pub fn size() -> Int => self.inbox.length + self.outbox.length
}

// ============================================================
// Deque<T> — Double-ended queue (safe, imutavel)
// ============================================================
// Complexidade: todas as operacoes O(n) por copia

pub struct Deque<T> {
  items: List<T>
}

extension Deque {
  static fn new() -> Deque<T> => Deque(items: [])

  // O(n) — prepend + copia
  pub fn pushFront(value: T) -> Deque<T> {
    return Deque(items: [value] + self.items)
  }

  // O(n) — append + copia
  pub fn pushBack(value: T) -> Deque<T> {
    return Deque(items: self.items + [value])
  }

  // O(n)
  pub fn popFront() -> Option<(T, Deque<T>)> {
    if self.items.length == 0 { return .none }
    let front = self.items[0]
    let rest = self.items.slice(1)
    return .some((front, Deque(items: rest)))
  }

  // O(n)
  pub fn popBack() -> Option<(T, Deque<T>)> {
    if self.items.length == 0 { return .none }
    let back = self.items[self.items.length - 1]
    let rest = self.items.slice(0, self.items.length - 1)
    return .some((back, Deque(items: rest)))
  }

  // O(1)
  pub fn peekFront() -> Option<T> {
    if self.items.length == 0 { return .none }
    return .some(self.items[0])
  }

  // O(1)
  pub fn peekBack() -> Option<T> {
    if self.items.length == 0 { return .none }
    return .some(self.items[self.items.length - 1])
  }

  pub fn isEmpty() -> Bool => self.items.length == 0
  pub fn size() -> Int => self.items.length
  pub fn toList() -> List<T> => self.items
}

// ============================================================
// MutDeque<T> — Double-ended queue (unsafe, mutavel)
// ============================================================
// Complexidade:
//   pushBack/popBack: O(1) amortizado
//   pushFront: O(n) — prepend em array
//   popFront:  O(n) — shift em array

pub struct MutDeque<T> {
  var items: List<T>
}

extension MutDeque {
  static fn new() -> MutDeque<T> => MutDeque(items: [])

  // O(n) — prepend
  pub fn pushFront(value: T) {
    self.items = [value] + self.items
  }

  // O(1) amortizado
  pub fn pushBack(value: T) {
    self.items = self.items + [value]
  }

  // O(n) — shift
  pub fn popFront() -> Option<T> {
    if self.items.length == 0 { return .none }
    let front = self.items[0]
    self.items = self.items.slice(1)
    return .some(front)
  }

  // O(1)
  pub fn popBack() -> Option<T> {
    if self.items.length == 0 { return .none }
    let back = self.items[self.items.length - 1]
    self.items = self.items.slice(0, self.items.length - 1)
    return .some(back)
  }

  pub fn isEmpty() -> Bool => self.items.length == 0
  pub fn size() -> Int => self.items.length
  pub fn toList() -> List<T> => self.items
}

// ============================================================
// PriorityQueue<T> — Min-heap (safe, imutavel)
// ============================================================
// Complexidade: insert/extract O(n log n) — cada swap copia a lista

pub struct PriorityQueue<T> {
  heap: List<T>
  compare: (T, T) -> Int
}

extension PriorityQueue {
  static fn new(compare: (T, T) -> Int) -> PriorityQueue<T> {
    return PriorityQueue(heap: [], compare: compare)
  }

  static fn minQueue() -> PriorityQueue<Int> {
    return PriorityQueue.new((a, b) => a - b)
  }

  static fn maxQueue() -> PriorityQueue<Int> {
    return PriorityQueue.new((a, b) => b - a)
  }

  // O(n log n) — sift-up com copia a cada swap
  pub fn insert(value: T) -> PriorityQueue<T> {
    var h = self.heap + [value]
    var i = h.length - 1
    while i > 0 {
      let parent = (i - 1) / 2
      if self.compare(h[i], h[parent]) < 0 {
        let temp = h[i]
        h = h.set(i, h[parent])
        h = h.set(parent, temp)
        i = parent
      } else {
        i = 0
      }
    }
    return PriorityQueue(heap: h, compare: self.compare)
  }

  // O(n log n) — sift-down com copia a cada swap
  pub fn extractTop() -> Option<(T, PriorityQueue<T>)> {
    if self.heap.length == 0 { return .none }
    if self.heap.length == 1 {
      return .some((self.heap[0], PriorityQueue(heap: [], compare: self.compare)))
    }
    let top = self.heap[0]
    var h = self.heap.set(0, self.heap[self.heap.length - 1])
    h = h.slice(0, h.length - 1)
    var i = 0
    while true {
      let left = 2 * i + 1
      let right = 2 * i + 2
      var smallest = i
      if left < h.length && self.compare(h[left], h[smallest]) < 0 {
        smallest = left
      }
      if right < h.length && self.compare(h[right], h[smallest]) < 0 {
        smallest = right
      }
      if smallest == i { return .some((top, PriorityQueue(heap: h, compare: self.compare))) }
      let temp = h[i]
      h = h.set(i, h[smallest])
      h = h.set(smallest, temp)
      i = smallest
    }
    return .some((top, PriorityQueue(heap: h, compare: self.compare)))
  }

  pub fn peek() -> Option<T> {
    if self.heap.length == 0 { return .none }
    return .some(self.heap[0])
  }

  pub fn isEmpty() -> Bool => self.heap.length == 0
  pub fn size() -> Int => self.heap.length
}

// ============================================================
// MutPriorityQueue<T> — Min-heap (unsafe, mutavel)
// ============================================================
// Complexidade: insert/extract O(log n) — swaps in-place

pub struct MutPriorityQueue<T> {
  var heap: List<T>
  compare: (T, T) -> Int
}

extension MutPriorityQueue {
  static fn new(compare: (T, T) -> Int) -> MutPriorityQueue<T> {
    return MutPriorityQueue(heap: [], compare: compare)
  }

  // O(log n) — sift-up in-place
  pub fn insert(value: T) {
    self.heap = self.heap + [value]
    var i = self.heap.length - 1
    while i > 0 {
      let parent = (i - 1) / 2
      if self.compare(self.heap[i], self.heap[parent]) < 0 {
        let temp = self.heap[i]
        self.heap = self.heap.set(i, self.heap[parent])
        self.heap = self.heap.set(parent, temp)
        i = parent
      } else {
        i = 0
      }
    }
  }

  // O(log n) — sift-down in-place
  pub fn extractTop() -> Option<T> {
    if self.heap.length == 0 { return .none }
    let top = self.heap[0]
    self.heap = self.heap.set(0, self.heap[self.heap.length - 1])
    self.heap = self.heap.slice(0, self.heap.length - 1)
    var i = 0
    while true {
      let left = 2 * i + 1
      let right = 2 * i + 2
      var smallest = i
      if left < self.heap.length && self.compare(self.heap[left], self.heap[smallest]) < 0 {
        smallest = left
      }
      if right < self.heap.length && self.compare(self.heap[right], self.heap[smallest]) < 0 {
        smallest = right
      }
      if smallest == i { return .some(top) }
      let temp = self.heap[i]
      self.heap = self.heap.set(i, self.heap[smallest])
      self.heap = self.heap.set(smallest, temp)
      i = smallest
    }
    return .some(top)
  }

  pub fn peek() -> Option<T> {
    if self.heap.length == 0 { return .none }
    return .some(self.heap[0])
  }

  pub fn isEmpty() -> Bool => self.heap.length == 0
  pub fn size() -> Int => self.heap.length
}

// ============================================================
// Ring<T> — Buffer circular (safe, imutavel)
// ============================================================
// Complexidade: push O(n) — copia a lista

pub struct Ring<T> {
  items: List<T>
  capacity: Int
  writePos: Int
}

extension Ring {
  static fn new(capacity: Int) -> Ring<T> {
    return Ring(items: [], capacity: capacity, writePos: 0)
  }

  // O(n)
  pub fn push(value: T) -> Ring<T> {
    if self.items.length < self.capacity {
      return Ring(
        items: self.items + [value],
        capacity: self.capacity,
        writePos: self.items.length + 1
      )
    }
    let pos = self.writePos % self.capacity
    return Ring(
      items: self.items.set(pos, value),
      capacity: self.capacity,
      writePos: self.writePos + 1
    )
  }

  pub fn toList() -> List<T> {
    if self.items.length < self.capacity { return self.items }
    let start = self.writePos % self.capacity
    return self.items.slice(start) + self.items.slice(0, start)
  }

  pub fn isFull() -> Bool => self.items.length == self.capacity
  pub fn size() -> Int => self.items.length
}

// ============================================================
// OrderedMap<K, V> — Map com ordem de insercao (safe, imutavel)
// ============================================================
// Complexidade: get/set/has O(n) — busca linear

pub struct OrderedMap<K, V> {
  keys: List<K>
  values: List<V>
}

extension OrderedMap {
  static fn new() -> OrderedMap<K, V> => OrderedMap(keys: [], values: [])

  // O(n)
  pub fn set(key: K, value: V) -> OrderedMap<K, V> {
    var i = 0
    while i < self.keys.length {
      if self.keys[i] == key {
        return OrderedMap(
          keys: self.keys,
          values: self.values.set(i, value)
        )
      }
      i += 1
    }
    return OrderedMap(
      keys: self.keys + [key],
      values: self.values + [value]
    )
  }

  // O(n)
  pub fn get(key: K) -> Option<V> {
    var i = 0
    while i < self.keys.length {
      if self.keys[i] == key { return .some(self.values[i]) }
      i += 1
    }
    return .none
  }

  // O(n)
  pub fn has(key: K) -> Bool {
    for k in self.keys {
      if k == key { return true }
    }
    return false
  }

  // O(n)
  pub fn remove(key: K) -> OrderedMap<K, V> {
    var newKeys: List<K> = []
    var newValues: List<V> = []
    var i = 0
    while i < self.keys.length {
      if self.keys[i] != key {
        newKeys = newKeys + [self.keys[i]]
        newValues = newValues + [self.values[i]]
      }
      i += 1
    }
    return OrderedMap(keys: newKeys, values: newValues)
  }

  pub fn size() -> Int => self.keys.length
  pub fn isEmpty() -> Bool => self.keys.length == 0

  pub fn entries() -> List<(K, V)> {
    var result: List<(K, V)> = []
    var i = 0
    while i < self.keys.length {
      result = result + [(self.keys[i], self.values[i])]
      i += 1
    }
    return result
  }
}

// ============================================================
// OrderedSet<T> — Set com ordem de insercao (safe, imutavel)
// ============================================================
// Complexidade: add/has O(n) — busca linear
// union/intersection: O(n*m)

pub struct OrderedSet<T> {
  items: List<T>
}

extension OrderedSet {
  static fn new() -> OrderedSet<T> => OrderedSet(items: [])

  // O(n) — verifica duplicata + copia
  pub fn add(value: T) -> OrderedSet<T> {
    for item in self.items {
      if item == value { return self }
    }
    return OrderedSet(items: self.items + [value])
  }

  // O(n)
  pub fn remove(value: T) -> OrderedSet<T> {
    var newItems: List<T> = []
    for item in self.items {
      if item != value { newItems = newItems + [item] }
    }
    return OrderedSet(items: newItems)
  }

  // O(n)
  pub fn has(value: T) -> Bool {
    for item in self.items {
      if item == value { return true }
    }
    return false
  }

  // O(n*m)
  pub fn union(other: OrderedSet<T>) -> OrderedSet<T> {
    var result = self
    for item in other.items {
      result = result.add(item)
    }
    return result
  }

  // O(n*m)
  pub fn intersection(other: OrderedSet<T>) -> OrderedSet<T> {
    var result = OrderedSet.new()
    for item in self.items {
      if other.has(item) { result = result.add(item) }
    }
    return result
  }

  // O(n*m)
  pub fn difference(other: OrderedSet<T>) -> OrderedSet<T> {
    var result = OrderedSet.new()
    for item in self.items {
      if !other.has(item) { result = result.add(item) }
    }
    return result
  }

  pub fn size() -> Int => self.items.length
  pub fn isEmpty() -> Bool => self.items.length == 0
  pub fn toList() -> List<T> => self.items
}

// ============================================================
// Graph<T> — Grafo não-dirigido
// ============================================================

struct Graph<T> {
  nodes: List<T>
  edges: List<(Int, Int)>
}

extension Graph {
  static fn new() -> Graph<T> => Graph(nodes: [], edges: [])

  fn addNode(value: T) -> Graph<T> {
    return Graph(nodes: self.nodes + [value], edges: self.edges)
  }

  fn addEdge(from: Int, to: Int) -> Graph<T> {
    return Graph(nodes: self.nodes, edges: self.edges + [(from, to)])
  }

  fn neighbors(node: Int) -> List<Int> {
    var result: List<Int> = []
    for edge in self.edges {
      let a = edge.0
      let b = edge.1
      if a == node { result = result + [b] }
      if b == node { result = result + [a] }
    }
    return result
  }

  fn hasEdge(from: Int, to: Int) -> Bool {
    for edge in self.edges {
      let a = edge.0
      let b = edge.1
      if (a == from && b == to) || (a == to && b == from) { return true }
    }
    return false
  }

  fn degree(node: Int) -> Int => self.neighbors(node).length

  fn nodeCount() -> Int => self.nodes.length
  fn edgeCount() -> Int => self.edges.length

  fn bfs(start: Int) -> List<Int> {
    var visited: List<Bool> = []
    var i = 0
    while i < self.nodes.length {
      visited = visited + [false]
      i += 1
    }
    var queue: List<Int> = [start]
    visited = visited.set(start, true)
    var result: List<Int> = []
    while queue.length > 0 {
      let current = queue[0]
      queue = queue.slice(1)
      result = result + [current]
      for neighbor in self.neighbors(current) {
        if !visited[neighbor] {
          visited = visited.set(neighbor, true)
          queue = queue + [neighbor]
        }
      }
    }
    return result
  }

  fn dfs(start: Int) -> List<Int> {
    var visited: List<Bool> = []
    var i = 0
    while i < self.nodes.length {
      visited = visited + [false]
      i += 1
    }
    var stack: List<Int> = [start]
    var result: List<Int> = []
    while stack.length > 0 {
      let current = stack[stack.length - 1]
      stack = stack.slice(0, stack.length - 1)
      if !visited[current] {
        visited = visited.set(current, true)
        result = result + [current]
        let neighbors = self.neighbors(current)
        var j = neighbors.length - 1
        while j >= 0 {
          if !visited[neighbors[j]] {
            stack = stack + [neighbors[j]]
          }
          j -= 1
        }
      }
    }
    return result
  }

  fn isConnected() -> Bool {
    if self.nodes.length == 0 { return true }
    let visited = self.bfs(0)
    return visited.length == self.nodes.length
  }

  fn hasCycle() -> Bool {
    var visited: List<Bool> = []
    var i = 0
    while i < self.nodes.length {
      visited = visited + [false]
      i += 1
    }
    i = 0
    while i < self.nodes.length {
      if !visited[i] {
        if self._hasCycleDfs(i, -1, visited) { return true }
      }
      i += 1
    }
    return false
  }

  fn _hasCycleDfs(node: Int, parent: Int, visited: List<Bool>) -> Bool {
    var vis = visited.set(node, true)
    for neighbor in self.neighbors(node) {
      if !vis[neighbor] {
        if self._hasCycleDfs(neighbor, node, vis) { return true }
      } else if neighbor != parent {
        return true
      }
    }
    return false
  }
}

// ============================================================
// DiGraph<T> — Grafo dirigido
// ============================================================

struct DiGraph<T> {
  nodes: List<T>
  edges: List<(Int, Int)>
}

extension DiGraph {
  static fn new() -> DiGraph<T> => DiGraph(nodes: [], edges: [])

  fn addNode(value: T) -> DiGraph<T> {
    return DiGraph(nodes: self.nodes + [value], edges: self.edges)
  }

  fn addEdge(from: Int, to: Int) -> DiGraph<T> {
    return DiGraph(nodes: self.nodes, edges: self.edges + [(from, to)])
  }

  fn successors(node: Int) -> List<Int> {
    var result: List<Int> = []
    for edge in self.edges {
      let a = edge.0
      let b = edge.1
      if a == node { result = result + [b] }
    }
    return result
  }

  fn predecessors(node: Int) -> List<Int> {
    var result: List<Int> = []
    for edge in self.edges {
      let a = edge.0
      let b = edge.1
      if b == node { result = result + [a] }
    }
    return result
  }

  fn hasEdge(from: Int, to: Int) -> Bool {
    for edge in self.edges {
      let a = edge.0
      let b = edge.1
      if a == from && b == to { return true }
    }
    return false
  }

  fn inDegree(node: Int) -> Int => self.predecessors(node).length
  fn outDegree(node: Int) -> Int => self.successors(node).length

  fn topologicalSort() -> Option<List<Int>> {
    var inDeg: List<Int> = []
    var i = 0
    while i < self.nodes.length {
      inDeg = inDeg + [0]
      i += 1
    }
    for edge in self.edges {
      let b = edge.1
      inDeg = inDeg.set(b, inDeg[b] + 1)
    }
    var queue: List<Int> = []
    i = 0
    while i < self.nodes.length {
      if inDeg[i] == 0 { queue = queue + [i] }
      i += 1
    }
    var result: List<Int> = []
    while queue.length > 0 {
      let current = queue[0]
      queue = queue.slice(1)
      result = result + [current]
      for neighbor in self.successors(current) {
        inDeg = inDeg.set(neighbor, inDeg[neighbor] - 1)
        if inDeg[neighbor] == 0 {
          queue = queue + [neighbor]
        }
      }
    }
    if result.length != self.nodes.length { return .none }
    return .some(result)
  }

  fn hasCycle() -> Bool {
    match self.topologicalSort() {
      .none => true,
      .some(_) => false
    }
  }

  fn bfs(start: Int) -> List<Int> {
    var visited: List<Bool> = []
    var i = 0
    while i < self.nodes.length {
      visited = visited + [false]
      i += 1
    }
    var queue: List<Int> = [start]
    visited = visited.set(start, true)
    var result: List<Int> = []
    while queue.length > 0 {
      let current = queue[0]
      queue = queue.slice(1)
      result = result + [current]
      for neighbor in self.successors(current) {
        if !visited[neighbor] {
          visited = visited.set(neighbor, true)
          queue = queue + [neighbor]
        }
      }
    }
    return result
  }

  fn dfs(start: Int) -> List<Int> {
    var visited: List<Bool> = []
    var i = 0
    while i < self.nodes.length {
      visited = visited + [false]
      i += 1
    }
    var stack: List<Int> = [start]
    var result: List<Int> = []
    while stack.length > 0 {
      let current = stack[stack.length - 1]
      stack = stack.slice(0, stack.length - 1)
      if !visited[current] {
        visited = visited.set(current, true)
        result = result + [current]
        let neighbors = self.successors(current)
        var j = neighbors.length - 1
        while j >= 0 {
          if !visited[neighbors[j]] {
            stack = stack + [neighbors[j]]
          }
          j -= 1
        }
      }
    }
    return result
  }
}

// ============================================================
// WeightedGraph<T> — Grafo ponderado (não-dirigido)
// ============================================================

struct WeightedEdge {
  from: Int
  to: Int
  weight: Float
}

struct WeightedGraph<T> {
  nodes: List<T>
  edges: List<WeightedEdge>
}

extension WeightedGraph {
  static fn new() -> WeightedGraph<T> => WeightedGraph(nodes: [], edges: [])

  fn addNode(value: T) -> WeightedGraph<T> {
    return WeightedGraph(nodes: self.nodes + [value], edges: self.edges)
  }

  fn addEdge(from: Int, to: Int, weight: Float) -> WeightedGraph<T> {
    let edge = WeightedEdge(from: from, to: to, weight: weight)
    return WeightedGraph(nodes: self.nodes, edges: self.edges + [edge])
  }

  fn neighbors(node: Int) -> List<(Int, Float)> {
    var result: List<(Int, Float)> = []
    for edge in self.edges {
      if edge.from == node { result = result + [(edge.to, edge.weight)] }
      if edge.to == node { result = result + [(edge.from, edge.weight)] }
    }
    return result
  }

  // Dijkstra — shortest path from source to target
  fn shortestPath(source: Int, target: Int) -> Option<(Float, List<Int>)> {
    let n = self.nodes.length
    let inf = 1.0 / 0.0

    // Initialize distances
    var dist: List<Float> = []
    var prev: List<Int> = []
    var visited: List<Bool> = []
    var i = 0
    while i < n {
      dist = dist + [inf]
      prev = prev + [-1]
      visited = visited + [false]
      i += 1
    }
    dist = dist.set(source, 0.0)

    // Main loop
    var remaining = n
    while remaining > 0 {
      // Find unvisited node with minimum distance
      var minDist = inf
      var u = -1
      i = 0
      while i < n {
        if !visited[i] && dist[i] < minDist {
          minDist = dist[i]
          u = i
        }
        i += 1
      }
      if u == -1 { return .none }
      if u == target {
        // Reconstruct path
        var path: List<Int> = []
        var current = target
        while current != -1 {
          path = [current] + path
          current = prev[current]
        }
        return .some((dist[target], path))
      }
      visited = visited.set(u, true)
      remaining -= 1

      for neighbor in self.neighbors(u) {
        let v = neighbor.0
        let w = neighbor.1
        let alt = dist[u] + w
        if alt < dist[v] {
          dist = dist.set(v, alt)
          prev = prev.set(v, u)
        }
      }
    }
    return .none
  }

  // Minimum Spanning Tree — Kruskal's algorithm
  fn mst() -> WeightedGraph<T> {
    let n = self.nodes.length
    // Sort edges by weight (insertion sort for simplicity)
    var sorted = self.edges
    var i = 1
    while i < sorted.length {
      let key = sorted[i]
      var j = i - 1
      while j >= 0 && sorted[j].weight > key.weight {
        sorted = sorted.set(j + 1, sorted[j])
        j -= 1
      }
      sorted = sorted.set(j + 1, key)
      i += 1
    }

    // Union-Find
    var parent: List<Int> = []
    var rank: List<Int> = []
    i = 0
    while i < n {
      parent = parent + [i]
      rank = rank + [0]
      i += 1
    }

    var result = WeightedGraph(nodes: self.nodes, edges: [])

    for edge in sorted {
      let rootA = _find(parent, edge.from)
      let rootB = _find(parent, edge.to)
      if rootA != rootB {
        result = WeightedGraph(nodes: result.nodes, edges: result.edges + [edge])
        // Union by rank
        if rank[rootA] < rank[rootB] {
          parent = parent.set(rootA, rootB)
        } else if rank[rootA] > rank[rootB] {
          parent = parent.set(rootB, rootA)
        } else {
          parent = parent.set(rootB, rootA)
          rank = rank.set(rootA, rank[rootA] + 1)
        }
      }
    }
    return result
  }
}

fn _find(parent: List<Int>, node: Int) -> Int {
  var current = node
  while parent[current] != current {
    current = parent[current]
  }
  return current
}

// ============================================================
// SORTING ALGORITHMS
// ============================================================

// === Merge Sort — O(n log n), stable ===

fn mergeSort<T>(list: List<T>, compare: (T, T) -> Int) -> List<T> {
  if list.length <= 1 { return list }
  let mid = list.length / 2
  let left = mergeSort(list.slice(0, mid), compare)
  let right = mergeSort(list.slice(mid), compare)
  return _merge(left, right, compare)
}

fn _merge<T>(left: List<T>, right: List<T>, compare: (T, T) -> Int) -> List<T> {
  var result: List<T> = []
  var i = 0
  var j = 0
  while i < left.length && j < right.length {
    if compare(left[i], right[j]) <= 0 {
      result = result + [left[i]]
      i += 1
    } else {
      result = result + [right[j]]
      j += 1
    }
  }
  while i < left.length {
    result = result + [left[i]]
    i += 1
  }
  while j < right.length {
    result = result + [right[j]]
    j += 1
  }
  return result
}

// === Quick Sort — O(n log n) average, in-place concept ===

fn quickSort<T>(list: List<T>, compare: (T, T) -> Int) -> List<T> {
  if list.length <= 1 { return list }
  let pivot = list[list.length / 2]
  var less: List<T> = []
  var equal: List<T> = []
  var greater: List<T> = []
  for item in list {
    let cmp = compare(item, pivot)
    if cmp < 0 {
      less = less + [item]
    } else if cmp == 0 {
      equal = equal + [item]
    } else {
      greater = greater + [item]
    }
  }
  return quickSort(less, compare) + equal + quickSort(greater, compare)
}

// === Heap Sort — O(n log n), not stable ===

fn heapSort<T>(list: List<T>, compare: (T, T) -> Int) -> List<T> {
  var h = list
  let n = h.length

  // Build max heap
  var i = n / 2 - 1
  while i >= 0 {
    h = _siftDown(h, i, n, compare)
    i -= 1
  }

  // Extract elements
  i = n - 1
  while i > 0 {
    let temp = h[0]
    h = h.set(0, h[i])
    h = h.set(i, temp)
    h = _siftDown(h, 0, i, compare)
    i -= 1
  }
  return h
}

fn _siftDown<T>(heap: List<T>, start: Int, end: Int, compare: (T, T) -> Int) -> List<T> {
  var h = heap
  var root = start
  while 2 * root + 1 < end {
    let left = 2 * root + 1
    let right = left + 1
    var largest = root
    if compare(h[left], h[largest]) > 0 { largest = left }
    if right < end && compare(h[right], h[largest]) > 0 { largest = right }
    if largest == root { return h }
    let temp = h[root]
    h = h.set(root, h[largest])
    h = h.set(largest, temp)
    root = largest
  }
  return h
}

// === Insertion Sort — O(n²), stable, good for small lists ===

fn insertionSort<T>(list: List<T>, compare: (T, T) -> Int) -> List<T> {
  var h = list
  var i = 1
  while i < h.length {
    let key = h[i]
    var j = i - 1
    while j >= 0 && compare(h[j], key) > 0 {
      h = h.set(j + 1, h[j])
      j -= 1
    }
    h = h.set(j + 1, key)
    i += 1
  }
  return h
}

// === Tim Sort — Hybrid: insertion + merge, O(n log n), stable ===

fn timSort<T>(list: List<T>, compare: (T, T) -> Int) -> List<T> {
  let minRun = 32
  var h = list
  let n = h.length

  // Sort small runs with insertion sort
  var i = 0
  while i < n {
    let end = min(i + minRun, n)
    let run = insertionSort(h.slice(i, end), compare)
    var j = 0
    while j < run.length {
      h = h.set(i + j, run[j])
      j += 1
    }
    i += minRun
  }

  // Merge runs
  var size = minRun
  while size < n {
    i = 0
    while i < n {
      let mid = min(i + size, n)
      let end = min(i + 2 * size, n)
      if mid < end {
        let merged = _merge(h.slice(i, mid), h.slice(mid, end), compare)
        var j = 0
        while j < merged.length {
          h = h.set(i + j, merged[j])
          j += 1
        }
      }
      i += 2 * size
    }
    size *= 2
  }
  return h
}

// === Radix Sort — O(nk) for integers ===

fn radixSort(list: List<Int>) -> List<Int> {
  if list.length <= 1 { return list }

  // Handle negatives: separate, sort positives, reverse negatives
  var negatives: List<Int> = []
  var positives: List<Int> = []
  for item in list {
    if item < 0 {
      negatives = negatives + [-item]
    } else {
      positives = positives + [item]
    }
  }

  positives = _radixSortPositive(positives)
  negatives = _radixSortPositive(negatives)

  // Reverse negatives and negate
  var result: List<Int> = []
  var i = negatives.length - 1
  while i >= 0 {
    result = result + [-negatives[i]]
    i -= 1
  }
  return result + positives
}

fn _radixSortPositive(list: List<Int>) -> List<Int> {
  if list.length <= 1 { return list }

  // Find max
  var maxVal = 0
  for item in list {
    if item > maxVal { maxVal = item }
  }

  var h = list
  var exp = 1
  while maxVal / exp > 0 {
    // Counting sort by digit
    var buckets: List<List<Int>> = []
    var i = 0
    while i < 10 {
      buckets = buckets + [[]]
      i += 1
    }
    for item in h {
      let digit = (item / exp) % 10
      buckets = buckets.set(digit, buckets[digit] + [item])
    }
    h = []
    i = 0
    while i < 10 {
      h = h + buckets[i]
      i += 1
    }
    exp *= 10
  }
  return h
}

// === Utility ===

fn isSorted<T>(list: List<T>, compare: (T, T) -> Int) -> Bool {
  if list.length <= 1 { return true }
  var i = 1
  while i < list.length {
    if compare(list[i - 1], list[i]) > 0 { return false }
    i += 1
  }
  return true
}

fn min(a: Int, b: Int) -> Int => match a { _ if a < b => a, _ => b }
