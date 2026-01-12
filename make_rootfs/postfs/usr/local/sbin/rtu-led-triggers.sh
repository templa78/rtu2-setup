#!/bin/bash
set -eu

set_timer_pattern() {
  led="$1"
  delay_on=${2}
  delay_off=${3}
  path="/sys/class/leds/${led}"

  echo "timer" > "$path/trigger"
  echo ${delay_on}  > "$path/delay_on"
  echo ${delay_off} > "$path/delay_off"
}

set_netdev_led() {
  led="$1"
  ifname="$2"
  interval=$3
  path="/sys/class/leds/$led"

  echo "netdev" > "${path}/trigger"
  echo "${ifname}" > "${path}/device_name"
  #echo 1 > "${path}/rx"
  echo 1 > "${path}/tx"
  echo 50 > "${path}/interval"
}

set_tty_led() {
  led="$1"
  tty="$2"
  path="/sys/class/leds/$led"

  echo "tty" > "$path/trigger"
  echo "$tty" > "$path/ttyname"
}

main() {
  set_timer_pattern "LED_STS" 10 490
  set_netdev_led "LED_LINK" "eth0" 100
  set_netdev_led "LED_LTE"  "usb1" 100
  set_tty_led "LED_RS485_1" "ttyS3"
  set_tty_led "LED_RS485_2" "ttyS4"
  set_tty_led "LED_RS485_3" "ttyS5"
  set_tty_led "LED_RS485_4" "ttyS6"
  #set_tty_led "LED_PULSE" "ttyS7"
}

main "$@"
