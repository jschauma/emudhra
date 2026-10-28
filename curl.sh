#!/bin/sh

#set -eu

BUNDLE=${1-}

TOOL_PATH=${TOOL_PATH:-curl}

rval=0

USED=$("$TOOL_PATH" ${BUNDLE:+--cacert ${BUNDLE}} -v -I		\
	"https://emudhra.we-have-a-problem.com/" 2>&1 |	\
		sed -n -e 's/.*CAfile: //p')

echo "Used CA file: ${USED}"

for url in							\
	'https://dv-g3b-aaa-emudhra.we-have-a-problem.com/'	\
	'https://dv-g3b-emudhra.we-have-a-problem.com/'; do
	"$TOOL_PATH" ${BUNDLE:+--cacert ${BUNDLE}} -s -I "${url}" >/dev/null 2>&1
	status=$?

	if [ "${status}" -eq 0 ]; then
		printf 'BAD: successful connection to %s\n' "$url" >&2
		rval=$((rval + 1))
	fi
done

exit "$rval"
