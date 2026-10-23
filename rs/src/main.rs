use reqwest::{Certificate, blocking::Client};
use std::{env, fs, process};

const URLS: &[&str] = &[
    "https://dv-g3b-aaa-emudhra.we-have-a-problem.com/",
    "https://dv-g3b-emudhra.we-have-a-problem.com/",
];

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut args = env::args_os().skip(1);
    let ca_bundle = args.next();

    let mut builder = Client::builder();

    builder = builder.use_native_tls();
    if let Some(path) = ca_bundle {
        let pem = fs::read(path)?;
        let certificates = Certificate::from_pem_bundle(&pem)?;

        if certificates.is_empty() {
            return Err("CA bundle contains no certificates".into());
        }

        builder = builder.use_rustls_tls().tls_built_in_root_certs(false);

        for certificate in certificates {
            builder = builder.add_root_certificate(certificate);
        }
    }

    let client = builder.build()?;
    let mut rval = 0;

    for &url in URLS {
        if client.head(url).send().is_ok() {
            eprintln!("BAD: successful connection to {}", url);
            rval += 1;
        }
    }

    process::exit(rval);
}
