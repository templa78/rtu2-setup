# install_base 이후에 추가로 더 설치할 것들만

# cp g3k_init
# cp g3k_util
# cp g3k_setrtc

apt-get update
apt-get install -y util-linux fdisk gdisk dosfstools
apt-get install -y mmc-utils usbutils 
apt-get install -y cryptsetup

#apt-get install -y ethtool
#apt-get install -y usbutils mmc-utils
#apt-get install -y apt-utils apt-transport-https software-properties-common dirmngr gnupg
#apt-get install -y python3-setuptools libsystemd-dev

# 확인 필요
# mtd-utils
