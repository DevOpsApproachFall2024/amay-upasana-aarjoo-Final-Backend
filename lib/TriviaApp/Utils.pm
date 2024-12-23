package TriviaApp::Utils;

use strict;
use warnings;
use JSON;
use Exporter 'import';

my $json = JSON::MaybeXS->new(allow_blessed => 1, convert_blessed => 1);

our @EXPORT_OK = qw(prepare_for_json);

sub prepare_for_json {
    my ($doc) = @_;

    if (ref($doc) eq 'HASH') {
        my %cleaned;
        while (my ($k, $v) = each %$doc) {
            if (ref($v) eq 'MongoDB::OID') {
                $cleaned{$k} = $v->hex;
            } elsif (ref($v) eq 'boolean') {
                $cleaned{$k} = $v ? JSON::true : JSON::false;
            } elsif (ref($v) eq 'HASH' || ref($v) eq 'ARRAY') {
                $cleaned{$k} = prepare_for_json($v);
            } else {
                $cleaned{$k} = $v;
            }
        }
        return \%cleaned;
    } elsif (ref($doc) eq 'ARRAY') {
        return [map { prepare_for_json($_) } @$doc];
    }
    return $doc;
}

1; # Required for modules
