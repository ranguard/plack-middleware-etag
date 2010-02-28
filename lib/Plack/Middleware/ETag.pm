package Plack::Middleware::ETag;

use strict;
use warnings;
use Digest::SHA;

our $VERSION = '0.01';

use parent qw/Plack::Middleware/;

sub call {
    my ( $self, $env ) = @_;

    my $res     = $self->app->($env);
    my $headers = $res->[1];

    $self->response_cb(
        $res,
        sub {
            my $res = shift;
            return unless defined $res->[2];
            return
                if ( Plack::Util::header_exists( $headers, 'ETag' )
                || $env->{REQUEST_METHOD} ne 'GET' );
            my $sha     = Digest::SHA->new;
            my $content = $res->[2];
            $sha->add(@$content);
            Plack::Util::header_set( $headers, 'ETag', $sha->hexdigest );
            return;
        }
    );
}

1;
__END__

=head1 NAME

Plack::Middleware::ETag - Adds automatically an ETag header.

=head1 SYNOPSIS

  use Plack::Builder;

  my $app = builder {
    enable "Plack::Middleware::ETag";
    sub {['200', ['Content-Type' => 'text/html'}, ['hello world']]};
  };

=head1 DESCRIPTION

Plack::Middleware::ETag adds automatically an ETag header.

=head1 AUTHOR

franck cuny E<lt>franck@lumberjaph.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
