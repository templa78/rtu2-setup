#!/bin/bash
set -euo pipefail
source /usr/local/lib/rtu-iptables-common.sh

src_file=""
if [[ "${1:-}" == "--file" ]]; then
  src_file="${2:-}"
  [[ -n "$src_file" ]] || exit $E_USAGE
fi

_do() {
  mkdir -p "$RULE_DIR" || return $E_STAGE
  chmod 755 "$RULE_DIR" || return $E_STAGE

  local tmp
  tmp="$(mktemp "${RULE_DIR}/user.candidate.XXXXXX")" || return $E_STAGE
  trap 'rm -f "${tmp:-}"' RETURN

  if [[ -n "$src_file" ]]; then
    cat "$src_file" > "$tmp" || return $E_STAGE
  else
    cat > "$tmp" || return $E_STAGE
  fi

  chmod 640 "$tmp" || return $E_STAGE

  # static check on temp file
  static_check_fragment_file "$tmp" || return $?

  mv -f "$tmp" "$USER_CANDIDATE" || return $E_STAGE
  echo "OK: staged candidate at $USER_CANDIDATE"
  return 0
}

with_lock _do || exit $?
exit 0
