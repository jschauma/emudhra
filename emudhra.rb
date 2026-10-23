require "net/http"
require "openssl"
require "uri"

URLS = [
	"https://dv-g3b-aaa-emudhra.we-have-a-problem.com/",
	"https://dv-g3b-emudhra.we-have-a-problem.com/"
].freeze

store = nil

file = OpenSSL::X509::DEFAULT_CERT_FILE

if ARGV[0]
	file = ARGV[0]
	store = OpenSSL::X509::Store.new
	store.add_file(ARGV[0])
end

warn "Using CA file: #{file}"

rval = 0

URLS.each do |url|
	uri = URI(url)
	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_PEER
	http.cert_store = store if store

	begin
		http.start { |connection| connection.head(uri.request_uri) }
	rescue StandardError
		next
	end

	warn "BAD: successful connection to #{url}"
	rval += 1
end

exit rval
