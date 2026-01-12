#!/bin/bash
set -euo pipefail

RULE_DIR="${RULE_DIR:-/etc/iptables.d}"
RUNTIME_DIR="${RUNTIME_DIR:-/run/rtu-iptables}"

BASE_RULES="${RULE_DIR}/00-base.rules"
SYSTEM_RULES="${RULE_DIR}/10-system.rules"
USER_RULES="${RULE_DIR}/20-user.rules"
USER_CANDIDATE="${RULE_DIR}/user.candidate"

CANDIDATE_V4="${RUNTIME_DIR}/candidate.v4"
LOCK_FILE="${RUNTIME_DIR}/lock"

# Exit codes
E_USAGE=2
E_MISSING=10
E_STATIC=11
E_VALIDATE=12
E_APPLY=13
E_PROMOTE=14
E_STAGE=15

ensure_runtime_dir() {
  mkdir -p "${RUNTIME_DIR}" || return $E_MISSING
  chmod 700 "${RUNTIME_DIR}" || return $E_MISSING
  return 0
}

with_lock() {
  ensure_runtime_dir || return $?
  exec 9>"${LOCK_FILE}" || return $E_MISSING
  flock -x 9 || return $E_MISSING
  "$@"
}

# system/user 조각에 대한 정적 검사
static_check_fragment_file() {
  local f="$1"
  [[ -f "$f" ]] || { echo "ERROR: missing file: $f" >&2; return $E_MISSING; }

  if grep -nE '^\s*\*(filter|nat|mangle|raw|security)\s*$' "$f" >/dev/null; then
    echo "ERROR: '$f' must not contain table header." >&2
    return $E_STATIC
  fi
  if grep -nE '^\s*COMMIT\s*$' "$f" >/dev/null; then
    echo "ERROR: '$f' must not contain COMMIT." >&2
    return $E_STATIC
  fi
  if grep -nE '(^|\s)-P(\s|$)|(^|\s)-F(\s|$)|(^|\s)-X(\s|$)|(^|\s)-D(\s|$)' "$f" >/dev/null; then
    echo "ERROR: '$f' contains forbidden operation." >&2
    return $E_STATIC
  fi
  return 0
}

# mode:
#   boot  → base + system + 20-user.rules
#   cand  → base + system + user.candidate
build_candidate_v4() {
  local mode="$1"

  ensure_runtime_dir || return $?

  [[ -f "$BASE_RULES" ]] || { echo "ERROR: missing $BASE_RULES" >&2; return $E_MISSING; }
  [[ -f "$SYSTEM_RULES" ]] || { echo "ERROR: missing $SYSTEM_RULES" >&2; return $E_MISSING; }

  static_check_fragment_file "$SYSTEM_RULES" || return $?

  local user_file
  case "$mode" in
    boot) user_file="$USER_RULES" ;;
    cand) user_file="$USER_CANDIDATE" ;;
    *) echo "ERROR: invalid mode $mode" >&2; return $E_USAGE ;;
  esac

  [[ -f "$user_file" ]] || { echo "ERROR: missing $user_file" >&2; return $E_MISSING; }
  static_check_fragment_file "$user_file" || return $?

  local tmp
  tmp="$(mktemp "${RUNTIME_DIR}/candidate.v4.XXXXXX")" || return $E_MISSING
  trap '[[ -n "${tmp:-}" ]] && rm -f "${tmp}"' RETURN

  {
    sed -e 's/\r$//' "$BASE_RULES"
    echo

    echo "# file: $SYSTEM_RULES"
    sed -e 's/\r$//' "$SYSTEM_RULES"
    echo

    echo "# file: $user_file"
    sed -e 's/\r$//' "$user_file"
    echo

    echo "COMMIT"
  } > "$tmp" || return $E_MISSING

  chmod 600 "$tmp" || return $E_MISSING
  mv -f "$tmp" "$CANDIDATE_V4" || return $E_MISSING
  return 0
}

validate_mode() {
  local mode="$1"

  build_candidate_v4 "$mode" || return $?

  if ! iptables-restore --test < "$CANDIDATE_V4"; then
    echo "ERROR: iptables-restore --test failed" >&2
    return $E_VALIDATE
  fi

  return 0
}
