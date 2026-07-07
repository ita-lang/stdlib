#!/usr/bin/env bash
#
# run_runtime.sh — Suíte de REGRESSÃO DE RUNTIME da stdlib (golden).
#
# Blinda o "12/12 roda": para cada stdlib/test/rt_<modulo>.tu, compila+roda via
# `itac run`, extrai a saída determinística do programa (tudo após o marcador
# "--- Running ---") e compara byte-a-byte com stdlib/test/rt_<modulo>.expected.
#
# Uso:
#   bash stdlib/test/run_runtime.sh            # roda e compara → PASS/FAIL
#   bash stdlib/test/run_runtime.sh --update   # (re)gera os .expected
#   bash stdlib/test/run_runtime.sh rt_math    # roda só um módulo (aceita nome ou path)
#
# Sai com código != 0 se algum teste falhar.
#
# --------------------------------------------------------------------------
# Variáveis de ambiente que o CI precisa exportar (paths ABSOLUTOS):
#
#   ITA_HOME           raiz do repo do compilador (`ita/`). Se setada, as 4
#                      variáveis abaixo são derivadas dela automaticamente.
#   ITA_DART_BIN       dart do SDK bootstrap    (.dart-sdk/.../bin/dart)
#   ITA_PLATFORM_DILL  vm_platform.dill do SDK  (.../lib/_internal/vm_platform.dill)
#   ITA_PACKAGES       package_config.json      (ita/compiler/.dart_tool/package_config.json)
#   ITA_ITAC           entrypoint do compilador (ita/compiler/bin/itac.dart)
#   ITA_STDLIB         pasta da stdlib          (resolve os imports dos módulos)
#
# Se nada for setado, o script assume o layout do workspace
# (ita-lang/{ita,stdlib}) a partir da própria localização deste arquivo.
# --------------------------------------------------------------------------

set -u

# --- Localização robusta (roda de qualquer CWD) ---------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../stdlib/test
STDLIB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"                    # .../stdlib
WORKSPACE_DIR="$(cd "$STDLIB_DIR/.." && pwd)"                 # .../ita-lang

# ITA_HOME (repo do compilador). Default: <workspace>/ita
ITA_HOME="${ITA_HOME:-$WORKSPACE_DIR/ita}"

# Deriva os paths do SDK a partir de ITA_HOME quando não vierem do ambiente.
_sdk="$ITA_HOME/.dart-sdk/3.12.2/dart-sdk"
ITA_DART_BIN="${ITA_DART_BIN:-$_sdk/bin/dart}"
ITA_PLATFORM_DILL="${ITA_PLATFORM_DILL:-$_sdk/lib/_internal/vm_platform.dill}"
ITA_PACKAGES="${ITA_PACKAGES:-$ITA_HOME/compiler/.dart_tool/package_config.json}"
ITA_ITAC="${ITA_ITAC:-$ITA_HOME/compiler/bin/itac.dart}"
ITA_STDLIB="${ITA_STDLIB:-$STDLIB_DIR}"

export ITA_DART_BIN ITA_PLATFORM_DILL ITA_PACKAGES ITA_STDLIB

# --- Sanidade do ambiente -------------------------------------------------
_fail_env=0
for pair in \
  "ITA_DART_BIN:$ITA_DART_BIN" \
  "ITA_PLATFORM_DILL:$ITA_PLATFORM_DILL" \
  "ITA_PACKAGES:$ITA_PACKAGES" \
  "ITA_ITAC:$ITA_ITAC" ; do
  name="${pair%%:*}"; path="${pair#*:}"
  if [ ! -e "$path" ]; then
    echo "ERRO: $name não encontrado: $path" >&2
    _fail_env=1
  fi
done
if [ ! -d "$ITA_STDLIB" ]; then
  echo "ERRO: ITA_STDLIB não é um diretório: $ITA_STDLIB" >&2
  _fail_env=1
fi
if [ "$_fail_env" -ne 0 ]; then
  echo "Ambiente incompleto. Exporte os ITA_* (veja o cabeçalho deste script)." >&2
  exit 2
fi

# --- Args -----------------------------------------------------------------
UPDATE=0
ONLY=""
for arg in "$@"; do
  case "$arg" in
    --update) UPDATE=1 ;;
    -h|--help) sed -n '2,40p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) ONLY="$(basename "$arg" .tu)" ;;
  esac
done

# Diretório de build temporário isolado (não polui o CWD do CI).
BUILD_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/ita_rt.XXXXXX")"
trap 'rm -rf "$BUILD_ROOT"' EXIT

# Extrai a saída do programa: tudo após a linha "--- Running ---".
_extract() { awk 'f; /^--- Running ---$/{f=1}'; }

run_one() {
  local tu="$1"
  # Compila/roda de dentro de um dir de build isolado para o itac escrever
  # seu build/ ali; o path do .tu é absoluto, então a resolução não muda.
  ( cd "$BUILD_ROOT" && "$ITA_DART_BIN" --packages="$ITA_PACKAGES" "$ITA_ITAC" run "$tu" ) 2>&1
}

pass=0
fail=0
failed_list=""

for tu in "$SCRIPT_DIR"/rt_*.tu; do
  [ -e "$tu" ] || continue
  mod="$(basename "$tu" .tu)"        # rt_<modulo>
  name="${mod#rt_}"                   # <modulo>
  if [ -n "$ONLY" ] && [ "$mod" != "$ONLY" ] && [ "$name" != "$ONLY" ]; then
    continue
  fi
  expected="$SCRIPT_DIR/$mod.expected"

  raw="$(run_one "$tu")"
  status=$?
  actual="$(printf '%s\n' "$raw" | _extract)"

  if [ "$UPDATE" -eq 1 ]; then
    if [ "$status" -ne 0 ]; then
      echo "SKIP  $name (exit $status — não gravando golden)"
      echo "$raw" | tail -20
      fail=$((fail + 1)); failed_list="$failed_list $name"
      continue
    fi
    printf '%s\n' "$actual" > "$expected"
    echo "WROTE $name -> $(basename "$expected")"
    continue
  fi

  if [ ! -f "$expected" ]; then
    echo "FAIL  $name (golden ausente: $(basename "$expected"))"
    fail=$((fail + 1)); failed_list="$failed_list $name"
    continue
  fi

  if [ "$status" -eq 0 ] && [ "$actual" = "$(cat "$expected")" ]; then
    echo "PASS  $name"
    pass=$((pass + 1))
  else
    echo "FAIL  $name"
    if [ "$status" -ne 0 ]; then echo "      (itac run saiu com código $status)"; fi
    diff <(printf '%s\n' "$(cat "$expected")") <(printf '%s\n' "$actual") | sed 's/^/      /' | head -30
    fail=$((fail + 1)); failed_list="$failed_list $name"
  fi
done

echo "--------------------------------------------------"
if [ "$UPDATE" -eq 1 ]; then
  echo "goldens atualizados. (falhas ao gerar:$([ -z "$failed_list" ] && echo ' nenhuma' || echo "$failed_list"))"
  [ "$fail" -eq 0 ] && exit 0 || exit 1
fi
echo "Resultado: $pass PASS, $fail FAIL"
if [ "$fail" -ne 0 ]; then
  echo "Falharam:$failed_list"
  exit 1
fi
exit 0
