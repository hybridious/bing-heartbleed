#!/bin/bash


help(){
echo -e "\n\033[0;31m[*]\033[0m Bing HeatBleed Scanner"
echo -e "\033[0;32m[+]\033[0m Author: MMxM | hc0der.blogspot.com\n"
echo -e "\033[0;31m[*]\033[0m Options:\n"
echo -e "\t-s <string to search>"
echo -e "\t-t <timeout> [not required]"
echo -e "\t-o <output file> [not required]\n"
echo -e "\033[0;32m[+]\033[0m Example:\n"
echo -e "\t\$ bash bing-hb.sh -s 'your search' -t 20 -o vuln.txt\n"
!
exit
}

time_o(){
	time_x=$1
	command=$2
	expect -c "set echo \"-noecho\"; set timeout $time_x; spawn -noecho $command; expect timeout { exit 1 } eof { exit 0 }"
}

check(){
	site=$1
	echo "quit" | openssl s_client -connect $site:443  -tlsextdebug 2>&1| grep 'server extension "heartbeat" (id=15)'
}

while getopts s:t:o: OPT; do
	case ${OPT} in
		s)dork=${OPTARG};;
		t)tim=${OPTARG};;
		o)output=${OPTARG};;
	esac
done

reg='^[0-9]+$'
[ "$dork" ] || help
[[ $tim =~ $reg ]] || tim=15

out="/tmp/"$RANDOM".txt"
uni="/tmp/"$RANDOM".txt"

echo -e "\n\033[0;32m[+]\033[0m Bing HeartBleed Scanner By MMxM"
echo -e "\033[0;32m[+]\033[0m Searching for: '$dork'\n"
echo -e "\033[0;31m[*]\033[0m Saving results to $out ..."
encoded=$(echo -n "$dork" | perl -MURI::Escape -ne 'print uri_escape($_)')

for((i=1;i<500;i+=10));do
	curl "http://www.bing.com/search?q=$encoded&first=$i&FORM=PERE" -A 'Mozilla/5.0 (Windows NT 6.2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36' -s | grep -Po '(?<=<li class="b_algo"><h2><a href=["]).*?(?=["])' >>$out || break;
done

echo -e "\033[0;32m[+]\033[0m Done $(wc -l $out | awk '{print $1}') url's extracted from bing\n"
echo -e "\033[0;31m[*]\033[0m Filtering the urls"
grep -Po '^https?:\/\/\K.*?(?=\/)' $out | sort | uniq >> $uni;
tot=$(wc -l $uni | awk '{print $1}')
echo -e "\033[0;32m[+]\033[0m Done $tot url's"
echo -e "\n\033[0;32m[+]\033[0m Starting Heartbleed Scanner with timeout of $tim seconds ...\n"
i=0

while read site ;do
	((i++))
	echo -e "\033[0;31m[\033[0m$i/$tot\033[0;31m]\033[0m Checking: $site"
	time_o $tim "bash check.sh $site $output"
done < $uni

echo -e "\n\033[0;32m[+]\033[0m Scanner 100% Complete\n"
rm $out $uni
