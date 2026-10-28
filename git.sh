#!/usr/bin/env sh

set -eu

TOOL_PATH=${TOOL_PATH:-git}

rval=0

for url in "g3.emsign.filippo.io" "aaa.emsign.filippo.io" ; do
	output=$(GIT_CURL_VERBOSE=1 "$TOOL_PATH" ls-remote "https://$url" 2>&1)
	result=$?

	printf '%s\n' "$output" | grep -Eo 'CAfile: .*' || true

	if [ "$result" -eq 0 ]; then
		printf 'BAD: successful connection to %s\n' "$url" >&2
		rval=$((rval + 1))
	fi
done

exit "$rval"
