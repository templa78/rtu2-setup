#!/bin/sh

## Download STM32 image
RST_GPIO=9                  # STM32 리셋 핀 제어용 GPIO 번호
BOOT0_GPIO=10               # STM32 BOOT0 핀 제어용 GPIO 번호
UART_PORT=/dev/ttyS8        # STM32와 연결된 UART 포트
STM32_BIN=./cskey.bin		# 업로드할 펌웨어 바이너리 경로

# STM32를 BOOT0=1 상태로 리셋 (부트로더 모드 진입)
gpioset gpiochip0 ${RST_GPIO}=1
gpioset gpiochip0 ${BOOT0_GPIO}=1
sleep 1
gpioset gpiochip0 ${RST_GPIO}=0

# stm_writer 유틸리티로 바이너리 전송 (UART 통해 .bin 쓰기)
# UART: Baudrate: 115200, Write: cskey.bin
/usr/bin/stm_writer -d ${UART_PORT} -b 115200 -w ${STM32_BIN}

# 다시 BOOT0을 LOW로 바꾸고, 리셋을 해제하여 일반 모드로 부팅
gpioset gpiochip0 ${RST_GPIO}=1
gpioset gpiochip0 ${BOOT0_GPIO}=0
sleep 1
gpioset gpiochip0 ${RST_GPIO}=0
