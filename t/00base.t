use strict;
use warnings;

use HTML::Entities;
use Test::More;

use_ok('Text::Transformer');

my $tf = Text::Transformer->new(
    'http://[A-Za-z0-9_\.\%\?\#\@/]+' => sub {
        my $url = shift;
        qq{<a href="@{[encode_entities($url)]}">@{[encode_entities($url)]}</a>};
    },
    '\@[A-Za-z0-9_]+' => sub {
        my $name = shift;
        $name =~ s/^\@//;
        qq{<a href="http://twitter.com/@{[encode_entities($name)]}">\@$name</a>};
    },
    '' => sub {
        my $text = shift;
        encode_entities($text);
    },
);
is(
    $tf->transform('@kazuho http://hello.com/ yesyes <b>'),
    '<a href="http://twitter.com/kazuho">@kazuho</a> <a href="http://hello.com/">http://hello.com/</a> yesyes &lt;b&gt;',
);

done_testing;
