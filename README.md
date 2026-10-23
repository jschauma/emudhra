eMudhra bundle checks
=====================

https://emudhra.we-have-a-problem.com/

Sure, your browsers are doing the right thing, but TLS
happens in just a few more places than just in the
browser.  So you need to check [all the
places](https://github.com/NixOS/nixpkgs/issues/576475)
a bundle could hide.  What a pain!

I don't have a solution for you, sorry.  But if you
want to just check whether a specific language does
the right thing out of the box, here are some simple
example programs.  Each one will silently return
nothing (because this is the Unix way) if everything's
peachy and report an error if it can connect to the
known bad sites.

The tool will use whatever the default is for the
given framework/language, but you can also specify an
alternate bundle to check against that.  If it knows
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
$ sh emudhra.sh 
Used CA file: /etc/ssl/certs/ca-certificates.crt
$ sh emudhra.sh
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
$ CURL_SSL_BACKEND=secure-transport sh emudhra.sh
/tmp/cert.pem.bad 
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
```

Somewhere in its dependencies, Rust does actual
blocklist checking on the compromised intermediates,
so even with a bundle that trusts eMudhra's root, it
fails to connect.
