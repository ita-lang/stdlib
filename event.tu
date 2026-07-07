// Foundation: Event
// Pub/Sub in-process, single isolate

struct Listener<T> {
  id: Int
  handler: (T) -> Void
  once: Bool
}

struct Emitter<T> {
  listeners: List<Listener<T>>
  nextId: Int
}

extension Emitter {
  static fn new() -> Emitter<T> {
    return Emitter(listeners: [], nextId: 0)
  }

  fn on(handler: (T) -> Void) -> (Int, Emitter<T>) {
    let listener = Listener(id: self.nextId, handler: handler, once: false)
    return (self.nextId, Emitter(
      listeners: self.listeners + [listener],
      nextId: self.nextId + 1
    ))
  }

  fn once(handler: (T) -> Void) -> (Int, Emitter<T>) {
    let listener = Listener(id: self.nextId, handler: handler, once: true)
    return (self.nextId, Emitter(
      listeners: self.listeners + [listener],
      nextId: self.nextId + 1
    ))
  }

  fn off(listenerId: Int) -> Emitter<T> {
    var newListeners: List<Listener<T>> = []
    for l in self.listeners {
      if l.id != listenerId { newListeners = newListeners + [l] }
    }
    return Emitter(listeners: newListeners, nextId: self.nextId)
  }

  fn dispatch(value: T) -> Emitter<T> {
    var remaining: List<Listener<T>> = []
    for l in self.listeners {
      l.handler(value)
      if !l.once { remaining = remaining + [l] }
    }
    return Emitter(listeners: remaining, nextId: self.nextId)
  }

  fn listenerCount() -> Int => self.listeners.length

  fn removeAll() -> Emitter<T> {
    return Emitter(listeners: [], nextId: self.nextId)
  }
}

// === EventBus — Multi-channel event bus ===

struct EventBus {
  channels: List<(String, Emitter<String>)>
}

extension EventBus {
  static fn new() -> EventBus {
    return EventBus(channels: [])
  }

  fn on(channel: String, handler: (String) -> Void) -> EventBus {
    let emitter = self._getOrCreate(channel)
    let updated = emitter.on(handler).1
    return self._setChannel(channel, updated)
  }

  fn dispatch(channel: String, value: String) -> EventBus {
    var i = 0
    while i < self.channels.length {
      let name = self.channels[i].0
      let emitter = self.channels[i].1
      if name == channel {
        let updated = emitter.dispatch(value)
        return self._setChannel(channel, updated)
      }
      i += 1
    }
    return self
  }

  fn _getOrCreate(channel: String) -> Emitter<String> {
    for entry in self.channels {
      let name = entry.0
      let emitter = entry.1
      if name == channel { return emitter }
    }
    return Emitter.new()
  }

  fn _setChannel(channel: String, emitter: Emitter<String>) -> EventBus {
    var newChannels: List<(String, Emitter<String>)> = []
    var found = false
    for entry in self.channels {
      let name = entry.0
      if name == channel {
        newChannels = newChannels + [(channel, emitter)]
        found = true
      } else {
        newChannels = newChannels + [entry]
      }
    }
    if !found { newChannels = newChannels + [(channel, emitter)] }
    return EventBus(channels: newChannels)
  }
}
