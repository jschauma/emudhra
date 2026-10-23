#!/usr/bin/env perl

use strict;
use warnings;
use LWP::UserAgent;
use IO::Socket::SSL;

my @URLS = (
	'https://dv-g3b-aaa-emudhra.we-have-a-problem.com/',
	'https://dv-g3b-emudhra.we-have-a-problem.com/',
);

my %OPTS = (verify_hostname => 1);
my %defaults = IO::Socket::SSL::default_ca();
for my $key (qw(SSL_ca_file SSL_ca_path)) {
	if (defined($defaults{$key})) {
		$OPTS{$key} = $defaults{$key};
	}
}

if (scalar(@ARGV)) {
	$OPTS{SSL_ca_file} = $ARGV[0];
	$OPTS{SSL_ca_path} = "";
}

for my $key (qw(SSL_ca_file SSL_ca_path)) {
	if (length($OPTS{$key} // '')) {
		print "Using $key: " . $OPTS{$key} . "\n";
	}
}

my $UA = LWP::UserAgent->new(ssl_opts => \%OPTS);

my $rval = 0;

for my $url (@URLS) {
	my $response = $UA->head($url);

	if ($response->content !~ m/certificate verify failed/) {
		printf STDERR "BAD: successful connection to $url\n";
		$rval++;
	}
}

exit $rval;
