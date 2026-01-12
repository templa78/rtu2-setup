#!/bin/bash
set -euo pipefail
source /usr/local/lib/rtu-iptables-common.sh

mode="boot"
case "${1:-}" in
  --boot|"") mode="boot" ;;
  --candidate) mode="cand" ;;
  *) exit $E_USAGE ;;
esac

_promote_candidate_to_user_rules() {
  [[ -f "$USER_CANDIDATE" ]] || { echo "ERROR: missing $USER_CANDIDATE" >&2; return $E_MISSING; }

  local tmp
  tmp="$(mktemp "${RULE_DIR}/20-user.rules.XXXXXX")" || return $E_PROMOTE
  trap 'rm -f "${tmp:-}"' RETURN

  cat "$USER_CANDIDATE" > "$tmp" || return $E_PROMOTE
  chmod 640 "$tmp" || return $E_PROMOTE

  static_check_fragment_file "$tmp" || return $?
  mv -f "$tmp" "$USER_RULES" || return $E_PROMOTE

  return 0
}

_do() {
  # validate (no nested lock)
  validate_mode "$mode" || return $?

  # apply
  if ! iptables-restore < "$CANDIDATE_V4"; then
    echo "ERROR: iptables-restore apply failed" >&2
    return $E_APPLY
  fi

  # if candidate mode: persist immediately
  if [[ "$mode" == "cand" ]]; then
    _promote_candidate_to_user_rules || return $?
    echo "OK: applied candidate and saved to $USER_RULES"
  else
    echo "OK: applied boot rules (base + system + saved user rules)."
  fi

  return 0
}

with_lock _do || exit $?
exit 0
