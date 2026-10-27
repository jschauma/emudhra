eMudhra bundle checks
=====================

https://emudhra.we-have-a-problem.com/

Sure, your browsers are doing the right thing, but TLS
happens in just a few more places than just in the
browser. So you need to check [all the
places](https://github.com/NixOS/nixpkgs/issues/576475)
a bundle could hide. What a pain!

I don't have a solution for you, sorry. But if you
want to just check whether a specific language does
the right thing out of the box, here are some simple
example programs. Each one will silently return
nothing (because this is the Unix way) if everything's
peachy and report an error if it can connect to the
known bad sites.

The tool will use whatever the default is for the
given framework/language, but you can also specify an
alternate bundle to check against that. If it knows
how, it will display which bundle / path it used.

Examples
--------

### Go

```
$ go run emudhra.go
$ go run emudhra.go /tmp/cert.pem.bad
BAD: successful connection to https://dv-g3b-aaa-emudhra.we-have-a-problem.com/
BAD: successful connection to https://dv-g3b-emudhra.we-have-a-problem.com/
exit status 2
$
```

### Java

```
$ java emudhra.java
Using CA file: /opt/homebrew/Cellar/openjdk/23.0.2/libexec/openjdk.jdk/Contents/Home/lib/security/cacerts
BAD: successful connection to https://dv-g3b-aaa-emudhra.we-have-a-problem.com/
BAD: successful connection to https://dv-g3b-emudhra.we-have-a-problem.com/
$ java emudhra.java  /etc/ssl/cert.pem
Using CA file: /etc/ssl/cert.pem
$
```

Consider adding the intermediates to your
`blocked.certs` as discussed
[here](https://glaforge.dev/posts/2026/10/21/the-emudhra-ca-compromise-why-your-jvm-is-vulnerable-and-how-to-fix-it/).

### Node

```
$ node emudhra.js
$ node emudhra.js /tmp/cert.pem.bad
BAD: successful connection to https://dv-g3b-aaa-emudhra.we-have-a-problem.com/
BAD: successful connection to https://dv-g3b-emudhra.we-have-a-problem.com/
$
```

### Perl

```
$ perl emudhra.pl
Using SSL_ca_file: /private/etc/ssl/cert.pem
$ perl emudhra.pl /tmp/cert.pem.bad
Using SSL_ca_file: /tmp/cert.pem.bad
BAD: successful connection to https://dv-g3b-aaa-emudhra.we-have-a-problem.com/
BAD: successful connection to https://dv-g3b-emudhra.we-have-a-problem.com/
$
```

### Python

```
$ python3 emudhra.py
Using CA file: /opt/homebrew/etc/openssl@4/cert.pem
$ python3 emudhra.py /tmp/cert.pem.bad
Using CA file: /tmp/cert.pem.bad
BAD: successful connection to https://dv-g3b-aaa-emudhra.we-have-a-problem.com/
BAD: successful connection to https://dv-g3b-emudhra.we-have-a-problem.com/
$
```

### Ruby

```
$ ruby emudhra.rb
Using CA file: /usr/lib/ssl/cert.pem
$ ruby emudhra.rb /tmp/cert.pem.bad
Using CA file: /tmp/cert.pem.bad
BAD: successful connection to https://dv-g3b-aaa-emudhra.we-have-a-problem.com/
BAD: successful connection to https://dv-g3b-emudhra.we-have-a-problem.com/
$
```

### Curl

```
$ sh curl.sh
Used CA file: /etc/ssl/certs/ca-certificates.crt
$ sh curl.sh
/tmp/cert.pem.bad
Used CA file: /tmp/cert.pem.bad
BAD: successful connection to https://dv-g3b-aaa-emudhra.we-have-a-problem.com/
BAD: successful connection to https://dv-g3b-emudhra.we-have-a-problem.com/
$
```

Note: on macOS, you can ask `curl(1)` to use the
native backend, which then rejects the connection in
all cases:

```
$ CURL_SSL_BACKEND=secure-transport sh curl.sh /tmp/cert.pem.bad
Used CA file:
$
```

### Rust

```
$ cd rs
$ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.35s
     Running `target/debug/rs`
$ cargo run -- /tmp/cert.pem.bad
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.17s
     Running `target/debug/rs /tmp/cert.pem.bad`
$
```

Or:

```
$ sh cargo.sh
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.05s
     Running `target/debug/rs`
$
```

Somewhere in its dependencies, Rust does actual
blocklist checking on the compromised intermediates,
so even with a bundle that trusts eMudhra's root, it
fails to connect.

### All together

```
$ ./test_all.sh
### Testing go from /opt/homebrew/bin/go...
go version go1.27.3 darwin/arm64

### Testing java from /usr/bin/java...
openjdk 21.0.9 2025-10-21 LTS
OpenJDK Runtime Environment Zulu21.46+19-CA (build 21.0.9+10-LTS)
BAD: successful connection to https://dv-g3b-aaa-emudhra.we-have-a-problem.com/
BAD: successful connection to https://dv-g3b-emudhra.we-have-a-problem.com/

### Testing node from /Users/narthur/.config/nvm/versions/node/v22.21.1/bin/node...
v22.21.1
BAD: successful connection to https://dv-g3b-emudhra.we-have-a-problem.com/

### Testing node from /opt/homebrew/bin/node...
v26.12.1

### Testing perl from /opt/homebrew/bin/perl...

This is perl 5, version 44, subversion 0 (v5.44.0) built for darwin-thread-multi-2level

### Testing perl from /usr/bin/perl...

This is perl 5, version 34, subversion 1 (v5.34.1) built for darwin-thread-multi-2level
BAD: successful connection to https://dv-g3b-aaa-emudhra.we-have-a-problem.com/
BAD: successful connection to https://dv-g3b-emudhra.we-have-a-problem.com/

### Testing python from /Users/narthur/.pyenv/shims/python...

### Testing python3 from /Users/narthur/.pyenv/shims/python3...
Python 3.15.0

### Testing python3 from /opt/homebrew/bin/python3...
Python 3.15.0

### Testing python3 from /usr/bin/python3...
Python 3.9.6
BAD: successful connection to https://dv-g3b-aaa-emudhra.we-have-a-problem.com/
BAD: successful connection to https://dv-g3b-emudhra.we-have-a-problem.com/

### Testing ruby from /usr/bin/ruby...
ruby 2.6.10p210 (2022-04-12 revision 67958) [universal.arm64e-darwin24]
BAD: successful connection to https://dv-g3b-aaa-emudhra.we-have-a-problem.com/
BAD: successful connection to https://dv-g3b-emudhra.we-have-a-problem.com/

### Testing curl from /usr/bin/curl...
curl 8.7.1 (x86_64-apple-darwin24.0) libcurl/8.7.1 (SecureTransport) LibreSSL/3.3.6 zlib/1.2.12 nghttp2/1.64.0
Release-Date: 2024-03-27
BAD: successful connection to https://dv-g3b-aaa-emudhra.we-have-a-problem.com/
BAD: successful connection to https://dv-g3b-emudhra.we-have-a-problem.com/

### Re-testing curl with the the CURL_SSL_BACKEND macOS workaround...
### Testing curl from /usr/bin/curl...
curl 8.7.1 (x86_64-apple-darwin24.0) libcurl/8.7.1 SecureTransport (LibreSSL/3.3.6) zlib/1.2.12 nghttp2/1.64.0
Release-Date: 2024-03-27

### Testing cargo from /opt/homebrew/bin/cargo...
cargo 1.99.1 (5f94df478 2026-08-27) (Homebrew)

### Testing git from /opt/homebrew/bin/git...
git version 2.56.0

### Testing git from /usr/bin/git...
git version 2.50.1 (Apple Git-155)

Done

$
```

`test_all.sh` will first print the tool version and then attempt the test.
If you see `BAD` it means there is a certificate problem.
Other errors (e.g. broken python shims) will be eaten,
and usually mean you won't see a version either.

To use the wrapper to just test one tool:

```
$ ./test_all.sh curl
### Testing curl from /usr/bin/curl...
curl 8.7.1 (x86_64-apple-darwin24.0) libcurl/8.7.1 (SecureTransport) LibreSSL/3.3.6 zlib/1.2.12 nghttp2/1.64.0
Release-Date: 2024-03-27
BAD: successful connection to https://dv-g3b-aaa-emudhra.we-have-a-problem.com/
BAD: successful connection to https://dv-g3b-emudhra.we-have-a-problem.com/

### Re-testing curl with the the CURL_SSL_BACKEND macOS workaround...
### Testing curl from /usr/bin/curl...
curl 8.7.1 (x86_64-apple-darwin24.0) libcurl/8.7.1 SecureTransport (LibreSSL/3.3.6) zlib/1.2.12 nghttp2/1.64.0
Release-Date: 2024-03-27

Done

$
```
