#!/usr/bin/env node

const fs = require("node:fs");
const https = require("node:https");
const tls = require("node:tls");

const URLS = [
	"https://dv-g3b-aaa-emudhra.we-have-a-problem.com/",
	"https://dv-g3b-emudhra.we-have-a-problem.com/",
];

const options = { method: "HEAD" };

if (process.argv[2]) {
	options.ca = fs.readFileSync(process.argv[2]);
}

function head(url, redirects = 0) {
	return new Promise((resolve, reject) => {
		const request = https.request(url, options, (response) => {
			response.resume();
			resolve();
		});

		request.on("error", reject);
		request.end();
	});
}

(async () => {
	let rval = 0;

	for (const url of URLS) {
		try {
			await head(url);
		} catch {
			continue;
		}

		console.error(`BAD: successful connection to ${url}`);
		rval++;
	}

	process.exitCode = rval;
})();
