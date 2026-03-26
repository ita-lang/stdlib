// Foundation: Config
// Gestão de configuração com TOML + Env + merge

struct Config {
  data: Map<String, String>

  fn new() -> Config {
    return Config { data: {} }
  }

  fn fromMap(map: Map<String, String>) -> Config {
    return Config { data: map }
  }

  fn load(path: String) -> Result<Config, String> {
    let content = File.read(path)
    match content {
      .ok(text) => {
        let parsed = Toml.parse(text)
        return .ok(Config { data: parsed })
      },
      .err(e) => .err("Failed to load config: ${e}")
    }
  }

  fn get(self, key: String) -> Option<String> {
    return self.data.get(key)
  }

  fn getString(self, key: String, default: String) -> String {
    match self.data.get(key) {
      .some(v) => v,
      .none => default
    }
  }

  fn getInt(self, key: String, default: Int) -> Int {
    match self.data.get(key) {
      .some(v) => v.toInt() ?? default,
      .none => default
    }
  }

  fn getBool(self, key: String, default: Bool) -> Bool {
    match self.data.get(key) {
      .some("true") => true,
      .some("false") => false,
      _ => default
    }
  }

  fn env(key: String, default: String) -> String {
    match Env.get(key) {
      .some(v) => v,
      .none => default
    }
  }

  fn envInt(key: String, default: Int) -> Int {
    match Env.get(key) {
      .some(v) => v.toInt() ?? default,
      .none => default
    }
  }

  fn envBool(key: String, default: Bool) -> Bool {
    match Env.get(key) {
      .some("true") => true,
      .some("1") => true,
      .some("false") => false,
      .some("0") => false,
      _ => default
    }
  }

  fn merge(self, other: Config) -> Config {
    var merged = self.data
    for key in other.data.keys() {
      merged = merged.set(key, other.data[key])
    }
    return Config { data: merged }
  }

  fn set(self, key: String, value: String) -> Config {
    return Config { data: self.data.set(key, value) }
  }

  fn has(self, key: String) -> Bool {
    match self.data.get(key) {
      .some(_) => true,
      .none => false
    }
  }

  fn keys(self) -> List<String> => self.data.keys()
}

// === App Config — loads from glu.toml + env overrides ===

fn loadAppConfig() -> Result<Config, String> {
  let base = Config.load("glu.toml")
  match base {
    .ok(config) => {
      // Env vars override TOML values (GLU_ prefix)
      var result = config
      for key in config.keys() {
        let envKey = "GLU_" + key.toUpperCase().replaceAll(".", "_")
        match Env.get(envKey) {
          .some(v) => result = result.set(key, v),
          .none => {}
        }
      }
      return .ok(result)
    },
    .err(e) => .err(e)
  }
}
