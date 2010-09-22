package String::Filter;

use strict;
use warnings;

use Regexp::Assemble;

sub new {
    my $klass = shift;
    die "# of arguments is not even"
        unless @_ % 2 == 0;
    my $self = bless {
        handlers => [],
        default_handler => sub { $_[0] },
    };
    my $ra = Regexp::Assemble->new();
    while (@_) {
        my $pattern = shift;
        my $subref = shift;
        if ($pattern ne '') {
            $ra->add($pattern);
            push @{$self->{handlers}}, [ qr/$pattern/, $subref ];
        } else {
            $self->{default_handler} = $subref;
        }
    }
    my $assembled = $ra->re;
    $self->{match} = qr/($assembled)/;
    return $self;
}

sub transform {
    my ($self, $text) = @_;
    my @ret;
    for my $token (split /$self->{match}/, $text) {
        # FIXME do we have to do this O(n) every time?
        for my $handler (@{$self->{handlers}}) {
            if ($token =~ /$handler->[0]/) {
                push @ret, $handler->[1]->($token);
                goto NEXT_TOKEN;
            }
        }
        push @ret, $self->{default_handler}->($token);
    NEXT_TOKEN:
        ;
    }
    return join '', @ret;
}

1;
