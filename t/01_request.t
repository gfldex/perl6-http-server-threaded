#!/usr/bin/env perl6

use lib 't/lib';
use starter;
use Test;

plan 12;

my $s = srv;
isa-ok $s, HTTP::Server::Threaded;
is $s.mws.elems, 0, 'Response stack contains no elements yet';
is $s.hws.elems, 0, 'Response stack contains no elements yet';

$s.handler(sub ($req,$res) {
  start {
    sleep 2;
  };
});

$s.handler(sub ($request, $response) {
  $response.headers<Content-Type> = 'text/plain';
  $response.headers<Connection>   = 'close';
  $response.status = 200;
  $response.write("");
  $response.close("Hello world!");
});
ok $s.hws.elems, 'Response stack contains elements';
isa-ok $s.hws[0], Sub;

start { 
  sleep 1;
  my $client = req;
  isa-ok $client, IO::Socket::INET;
  is $client.host, host, 'IO::Socket::INET correct host';
  is $client.port, port, 'IO::Socket::INET correct port';

  $client.send("GET / HTTP/1.0\r\n\r\n");
  my $ret = '';
  while (my $str = $client.recv) {
    $ret ~= $str;
  }
  $client.close;
  ok $ret.match(/ ^^ 'HTTP/1.1 200 OK' $$ /), 'HTTP Status Code: 200';
  ok $ret.match(/ ^^ 'Content-Type: text/plain' $$ /), 'Content-Type';
  ok $ret.match(/ ^^ 'Content-Length: 12' $$ /), 'Content-Length';
  ok $ret.match(/ ^^ 'Hello world!' $$ /), "Content: Hello World!";
  exit 0;
};

$s.listen; 
# vi:syntax=perl6
