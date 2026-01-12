#!/bin/bash
set -euo pipefail
source /usr/local/lib/rtu-iptables-common.sh

mode="boot"
case "${1:-}" in
  --boot|"") mode="boot" ;;
  --candidate) mode="cand" ;;
  *) exit $E_USAGE ;;
esac

_do() {
  validate_mode "$mode" || return $?
  echo "OK: ruleset valid. mode=${mode}"
  return 0
}

with_lock _do || exit $?
exit 0
