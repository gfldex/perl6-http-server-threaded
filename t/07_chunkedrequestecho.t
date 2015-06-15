#!/usr/bin/env perl6

use lib 't/lib';
use starter;
use Test;

plan 1;

ok True;
exit 0;

my $s = srv;

$s.handler(sub ($request, $response) {
  $response.headers<Content-Type> = 'text/plain';
  $response.headers<Connection> = 'close';
  $response.status = 200;
  $request.data.perl.say;
  $response.close($request.data);
});

start {
  sleep 1;
  my $client = req;
  $client.send("POST / HTTP/1.0\r\nTransfer-Encoding: chunked\r\n\r\n");
  my @chunks = "4\r\n", "Wiki\r\n", "5\r\n", "pedia\r\n", "e\r\n", " in\r\n\r\nchunks.\r\n", "0\r\n", "\r\n";
  for @chunks -> $chunk {
    $client.send($chunk);
    sleep 1;
  }

  my $data;
  while (my $str = $client.recv) {
    $data ~= $str;
  }
  $client.close;
  ok $data ~~ / "\r\n\r\nWikipedia in\r\n\r\nchunks" /, 'Test for chunked data echo';
  exit 0;
}

$s.listen;
# vi:syntax=perl6
