use strict;
use warnings;
use Test::More;

use Digest::SHA;

use Plack::Test;
use Plack::Builder;
use HTTP::Request::Common;

my $content = [qw/hello world/];
my $sha = Digest::SHA->new->add(@$content)->hexdigest;

my $handler = builder {
    enable "Plack::Middleware::ETag";
    sub { [ '200', [ 'Content-Type' => 'text/html' ], $content ] };
};

my $second_handler = builder {
    enable "Plack::Middleware::ETag";
    sub {
        [
            '200', [ 'Content-Type' => 'text/html', 'ETag' => '123' ],
            $content
        ];
    };
};

my $unmodified_handler = builder {
    enable "Plack::Middleware::ConditionalGET";
    enable "Plack::Middleware::ETag";
    sub { [ '200', [ 'Content-Type' => 'text/html' ], $content ] };
};

test_psgi
    app    => $handler,
    client => sub {
    my $cb = shift;
    {
        my $req = GET "http://localhost/";
        my $res = $cb->($req);
        ok $res->header('ETag');
        is $res->header('ETag'), $sha;
    }
};

test_psgi
    app    => $second_handler,
    client => sub {
    my $cb = shift;
    {
        my $req = GET "http://localhost/";
        my $res = $cb->($req);
        ok $res->header('ETag');
        is $res->header('ETag'), '123';
    }
};

test_psgi
    app    => $unmodified_handler,
    client => sub {
    my $cb = shift;
    {
        my $req = GET "http://localhost/", 'If-None-Match' => $sha;
        my $res = $cb->($req);
        ok $res->header('ETag');
	is $res->code, 304;
	ok !$res->content;
    }
};

done_testing;
