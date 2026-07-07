// Foundation: Config
// Gestão de configuração com TOML + Env + merge

struct Config {
  data: Map<String, String>
}

extension Config {
  static fn new() -> Config {
    return Config(data: {})
  }

  static fn fromMap(map: Map<String, String>) -> Config {
    return Config(data: map)
  }

  static fn load(path: String) -> Result<Config, String> {
    let content = File.read(path)
    match content {
      .ok(text) => .ok(Config(data: Toml.parse(text))),
      .err(e) => .err("Failed to load config: ${e}")
    }
  }

  fn get(key: String) -> Option<String> {
    return self.data.get(key)
  }

  fn getString(key: String, default: String) -> String {
    match self.data.get(key) {
      .some(v) => v,
      .none => default
    }
  }

  fn getInt(key: String, default: Int) -> Int {
    match self.data.get(key) {
      .some(v) => v.toInt() ?? default,
      .none => default
    }
  }

  fn getBool(key: String, default: Bool) -> Bool {
    match self.data.get(key) {
      .some("true") => true,
      .some("false") => false,
      _ => default
    }
  }

  static fn env(key: String, default: String) -> String {
    match Env.get(key) {
      .some(v) => v,
      .none => default
    }
  }

  static fn envInt(key: String, default: Int) -> Int {
    match Env.get(key) {
      .some(v) => v.toInt() ?? default,
      .none => default
    }
  }

  static fn envBool(key: String, default: Bool) -> Bool {
    match Env.get(key) {
      .some("true") => true,
      .some("1") => true,
      .some("false") => false,
      .some("0") => false,
      _ => default
    }
  }

  fn merge(other: Config) -> Config {
    var merged = self.data
    for key in other.data.keys() {
      merged = merged.set(key, other.data[key])
    }
    return Config(data: merged)
  }

  fn set(key: String, value: String) -> Config {
    return Config(data: self.data.set(key, value))
  }

  fn has(key: String) -> Bool {
    match self.data.get(key) {
      .some(_) => true,
      .none => false
    }
  }

  fn keys() -> List<String> => self.data.keys()
}

// === App Config — loads from config.toml + env overrides ===

fn _applyEnvOverrides(config: Config) -> Result<Config, String> {
  // Env vars override TOML values (ITA_ prefix)
  var result = config
  for key in config.keys() {
    let envKey = "ITA_" + key.toUpperCase().replaceAll(".", "_")
    match Env.get(envKey) {
      .some(v) => result = result.set(key, v),
      .none => {}
    }
  }
  return .ok(result)
}

fn loadAppConfig() -> Result<Config, String> {
  let base = Config.load("config.toml")
  match base {
    .ok(config) => _applyEnvOverrides(config),
    .err(e) => .err(e)
  }
}
