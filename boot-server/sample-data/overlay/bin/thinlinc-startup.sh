#!/bin/sh
cd $HOME
pkill -0 -f xterm || xterm &
pkill -0 -f remmina || remmina &
MAC_ADDR=$(cat /sys/class/net/$(ip route show default | awk '/default/ {print $5}')/address)
/usr/bin/curl ${BASE_PATH}/home.pkg?mac=${MAC_ADDR} | /bin/tar -zxf -
/bin/tlclient
mkdir -p .config/freerdp .config/remmina .local/share/remmina .thinlinc
/bin/tar zcf /tmp/$$.tar.gz .config/freerdp .config/remmina .local/share/remmina .thinlinc && /usr/bin/curl -F data=@/tmp/$$.tar.gz ${BASE_PATH}/home.pkg?mac=${MAC_ADDR}
rm /tmp/$$.tar.gz