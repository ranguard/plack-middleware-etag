use strict;
use warnings;
use Test::More;

use Digest::SHA;

use Plack::Test;
use Plack::Builder;
use HTTP::Request::Common;

my $content = [qw/hello world/];

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

test_psgi
    app    => $handler,
    client => sub {
    my $cb = shift;
    {
        my $req = GET "http://localhost/";
        my $res = $cb->($req);
        ok $res->header('ETag');
        my $sha = Digest::SHA->new->add(@$content);
        is $res->header('ETag'), $sha->hexdigest;
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

done_testing;
