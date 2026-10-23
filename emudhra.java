import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.KeyStore;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;
import java.util.Collection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;

class EMudhra {
	private static final String[] URLS = {
		"https://dv-g3b-aaa-emudhra.we-have-a-problem.com/",
		"https://dv-g3b-emudhra.we-have-a-problem.com/"
	};

	public static void main(String[] args) throws Exception {
		HttpClient.Builder builder = HttpClient.newBuilder()
			.followRedirects(HttpClient.Redirect.NORMAL);
	
		String trustStore = System.getProperty("javax.net.ssl.trustStore");
		if (trustStore == null) {
			Path security = Path.of(
					System.getProperty("java.home"), "lib", "security"
					);
			Path path = security.resolve("jssecacerts");
			if (!Files.exists(path)) {
				path = security.resolve("cacerts");
			}
			trustStore = path.toString();
		}

		if (args.length > 0) {
			trustStore = args[0];
			CertificateFactory factory = CertificateFactory.getInstance("X.509");
			Collection<? extends Certificate> certificates;

			try (InputStream input = Files.newInputStream(Path.of(trustStore))) {
				certificates = factory.generateCertificates(input);
			}

			if (certificates.isEmpty()) {
				throw new IllegalArgumentException(
					"CA bundle contains no certificates"
				);
			}

			KeyStore store = KeyStore.getInstance(KeyStore.getDefaultType());
			store.load(null, null);

			int index = 0;
			for (Certificate certificate : certificates) {
				store.setCertificateEntry("ca-" + index++, certificate);
			}

			TrustManagerFactory managers = TrustManagerFactory.getInstance(
				TrustManagerFactory.getDefaultAlgorithm()
			);
			managers.init(store);

			SSLContext context = SSLContext.getInstance("TLS");
			context.init(null, managers.getTrustManagers(), null);
			builder.sslContext(context);
		}

		System.err.println("Using CA file: " + trustStore);

		HttpClient client = builder.build();
		int rval = 0;

		for (String url : URLS) {
			HttpRequest request = HttpRequest.newBuilder(URI.create(url))
				.method("HEAD", HttpRequest.BodyPublishers.noBody())
				.build();

			try {
				client.send(request, HttpResponse.BodyHandlers.discarding());
			} catch (InterruptedException e) {
				Thread.currentThread().interrupt();
				break;
			} catch (Exception e) {
				continue;
			}

			System.err.printf("BAD: successful connection to %s%n", url);
			rval++;
		}

		System.exit(rval);
	}
}
