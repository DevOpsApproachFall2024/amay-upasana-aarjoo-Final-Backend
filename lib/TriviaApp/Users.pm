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

my $pbkdf2 = Crypt::PBKDF2->new(
    hash_class => 'HMACSHA2',
    hash_args => {
        sha_size => 512,
    },
    iterations => 10000,
    salt_len => 16,
);

# Middleware to check authentication
hook 'before' => sub {
    # Skip authentication for login and register routes
    if (request->path_info =~ m{^/api/users/(login|register)$}) {
        return;
    }
    
    # Check for protected routes
    if (request->path_info =~ m{^/api/}) {
        unless (session('user_id')) {
            status 401;
            return halt($json->encode({ error => 'Authentication required' }));
        }
    }
};


1;
