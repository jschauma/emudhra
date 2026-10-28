#!/usr/bin/env sh

set -eu

TOOL_FILTER=${1:-}

find_all_on_path() (
	tool=$1
	remaining_path=$PATH:

	while [ -n "$remaining_path" ]; do
		dir=${remaining_path%%:*}
		remaining_path=${remaining_path#*:}
		[ -n "$dir" ] || dir=.

		if [ -f "$dir/$tool" ] && [ -x "$dir/$tool" ]; then
			printf '%s\n' "$dir/$tool"
		fi
	done
)

test_tool() {
	tool_to_test=$1
	extension=$2
	tool_to_run=${3:-$1}

	if [ -n "$TOOL_FILTER" ] && [ "$TOOL_FILTER" != "$tool_to_test" ]; then
		return 0
	fi

	if ! command -v "$tool_to_test" >/dev/null 2>&1 ; then
		echo "No '$tool_to_test' found"
		echo
	else
		find_all_on_path "$tool_to_test" | while IFS= read -r location; do
			echo "### Testing $tool_to_test from $location..."
			( "$location" --version 2>/dev/null || "$location" version 2>/dev/null ) | head -n 2 || true

			if [ "$tool_to_run" != "$tool_to_test" ]; then
			(
				TOOL_PATH=$location
				export TOOL_PATH
				"$tool_to_run" "$tool_to_test.$extension" 2>&1 | grep BAD || true
			)
			else
				"$location" "emudhra.$extension" 2>&1 | grep BAD || true
			fi
			echo
		done
	fi
}


set -- \
	go go \
	java java \
	node js \
	perl pl \
	python py \
	python3 py \
	ruby rb

while [ "$#" -gt 0 ]; do
	test_tool "$1" "$2"
	shift 2
done

test_tool curl sh sh

if [ "$(uname -s)" = "Darwin" ]; then
(
	if [ -z "$TOOL_FILTER" ] || [ "$TOOL_FILTER" = "curl" ]; then
		echo "### Re-testing curl with the the CURL_SSL_BACKEND macOS workaround..."
		export CURL_SSL_BACKEND=secure-transport
		test_tool curl sh sh
	fi
)
fi

test_tool cargo sh sh

test_tool git sh sh

echo "Done"

