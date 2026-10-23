package main

import (
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"net/http"
	"os"
)

var URLS = []string{
	"https://dv-g3b-aaa-emudhra.we-have-a-problem.com/",
	"https://dv-g3b-emudhra.we-have-a-problem.com/",
}

func main() {
	transport := http.DefaultTransport.(*http.Transport).Clone()

	if len(os.Args) > 1 {
		pem, err := os.ReadFile(os.Args[1])
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}

		roots := x509.NewCertPool()
		if !roots.AppendCertsFromPEM(pem) {
			fmt.Fprintln(os.Stderr, "CA bundle contains no valid certificates")
			os.Exit(1)
		}

		transport.TLSClientConfig = &tls.Config{RootCAs: roots}
	}

	client := &http.Client{Transport: transport}
	rval := 0

	for _, u := range URLS {
		if response, err := client.Head(u); err == nil {
			response.Body.Close()
			fmt.Fprintf(os.Stderr, "BAD: successful connection to %s\n", u)
			rval++
		}
	}

	os.Exit(rval)
}
