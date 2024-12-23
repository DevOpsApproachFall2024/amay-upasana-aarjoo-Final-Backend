package TriviaApp::Users;

use strict;
use warnings;
use Dancer2 appname => 'TriviaApp';
use MongoDB;
use JSON;
use JSON::MaybeXS;
use MongoDB::OID;
use Crypt::PBKDF2;
use TriviaApp::Utils qw(prepare_for_json);

my $json = JSON::MaybeXS->new(allow_blessed => 1, convert_blessed => 1);

my $client = MongoDB->connect("mongodb://localhost:27017");
my $database = $client->get_database('trivia_app');
my $collection = $database->get_collection('users');




1;
