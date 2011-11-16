#!/bin/sh

_get_projs() {
	curl "$1" | grep -E "/$2"'/([^"]+)">\1' \
	| sed -e 's#[^>]*>\([^<]*\)<.*#'"$2/"'\1#' -e 's#^'"$2/$2"'$##' \
	| grep -E '^.+'
}

get_projs() {
	i=0
	while [ 1 ]; do
		i=$(($i + 1))
		URL="https://github.com/$1/repositories/?page=$i"
		echo >&2 "$URL"
		PROJS=`_get_projs "$URL" $1`
		echo >&2 ""
		if [ $(echo "$PROJS" | wc -l) -eq 1 ]; then
			break
		fi
		echo "$PROJS"
	done
}

HEAD=$((`grep -n '<project ' default.xml | head -n 1 | cut -d ':' -f 1` - 1))
TAIL=$((`grep -n '<project ' default.xml | tail -n 1 | cut -d ':' -f 1` + 1))

head -n $HEAD default.xml
get_projs CyanogenMod | sed -e 's#\(.*\)#  <project name="\1" />#'
tail -n +$TAIL default.xml
