#!/bin/sh
cd $HOME
pkill -f xterm || xterm &
pkill -f remmina || remmina &
MAC_ADDR=$(cat /sys/class/net/$(ip route show default | awk '/default/ {print $5}')/address)
/usr/bin/curl ${BASE_PATH}/home.pkg?mac=${MAC_ADDR} | /bin/tar -zxf -
/bin/tlclient
/bin/tar zcf /tmp/$$.tar.gz .thinlinc/* && /usr/bin/curl -F data=@/tmp/$$.tar.gz ${BASE_PATH}/home.pkg?mac=${MAC_ADDR}
rm /tmp/$$.tar.gz