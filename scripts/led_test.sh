#!/bin/sh

LED_DIR=/sys/class/leds
for led in LED_RS485_1  LED_RS485_2  LED_RS485_3  LED_RS485_4 LED_LINK  LED_PULSE   LED_LTE   LED_STS
do
	echo 1 > ${LED_DIR}/${led}/brightness
	sleep 0.25
	echo 0 > ${LED_DIR}/${led}/brightness
	sleep 0.25
done
