import ssl
import sys
import urllib.error
import urllib.request

URLS = [
	"https://dv-g3b-aaa-emudhra.we-have-a-problem.com/",
	"https://dv-g3b-emudhra.we-have-a-problem.com/",
]

paths = ssl.get_default_verify_paths()
bundle = paths.cafile

if len(sys.argv) > 1:
    bundle = sys.argv[1]

context = ssl.create_default_context(
	cafile = bundle
)

if not bundle:
	print(f"Using CA path: {paths.capath}", file=sys.stdout)
else:
	print(f"Using CA file: {bundle}", file=sys.stdout)

rval = 0

for url in URLS:
	request = urllib.request.Request(url, method="HEAD")

	try:
		with urllib.request.urlopen(request, context=context):
			pass
	except urllib.error.HTTPError as response:
		# HTTP error statuses still indicate a
		# successful connection.
		response.close()
	except Exception:
		continue

	print(f"BAD: successful connection to {url}", file=sys.stderr)
	rval += 1

sys.exit(rval)
