#!/bin/bash

site=$1
echo "quit" | openssl s_client -connect $site:443  -tlsextdebug 2>&1| grep 'server extension "heartbeat" (id=15)' >/dev/null

if [ $? == 0 ];then
        echo -e "\033[1;32m[+]\033[0m Target Potentially Vulnerable !";
        [ "$2" ] && echo $site >> $2
fi
