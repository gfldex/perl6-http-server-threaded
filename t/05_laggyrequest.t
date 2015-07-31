#!/usr/bin/env perl6

use lib 't/lib';
use starter;
use Test;

plan 1;

my $s = srv;

$s.handler(sub ($request, $response) {
  $response.unbuffer;
  $response.headers<Connection> = 'close';
  $response.close('Hello');
});


start {
  sleep 1;
  my $client = req;
  $client.print("GET / HTTP/1.0\r\n");
  sleep 10;
  $client.print("\r\n");
  my $data;
  while (my $str = $client.recv) {
    $data ~= $str;
  }
  ok $data.match(/'Hello'/), 'Response';
  $client.close;
  exit 0;
}
$s.listen;

# vi:syntax=perl6
