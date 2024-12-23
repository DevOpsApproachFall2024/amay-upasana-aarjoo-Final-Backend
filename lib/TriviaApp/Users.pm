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

prefix '/api/users' => sub {
    post '/register' => sub {
        my $data = from_json(request->body);

        unless ($data->{email} && $data->{password}) {
            status 400;
            return  $json->encode({ error => 'Email and password required' });
        }

        if ($collection->find_one({ email => $data->{email} })) {
            status 409;
            return  $json->encode({ error => 'Email already registered' });
        }

        my $hashed_password = $pbkdf2->generate($data->{password});
        $collection->insert_one({
            email      => $data->{email},
            password   => $hashed_password,
            created_at => time(),
        });

        status 201;
        return  $json->encode({ success => 1, message => 'User registered successfully' });
    };

    post '/login' => sub {
        my $data = from_json(request->body);

        unless ($data->{email} && $data->{password}) {
            status 400;
            return  $json->encode({ error => 'Email and password required' });
        }

        my $user = $collection->find_one({ email => $data->{email} });
        unless ($user) {
            status 401;
            return  $json->encode({ error => 'Invalid credentials' });
        }

        unless ($pbkdf2->validate($user->{password}, $data->{password})) {
            status 401;
            return  $json->encode({ error => 'Invalid credentials' });
        }

        session user_id => $user->{_id}->hex;
        session email   => $user->{email};

        return  $json->encode({
            success => 1,
            user    => {
                id    => $user->{_id}->hex,
                email => $user->{email},
            },
        });
    };

    get '/profile' => sub {
        my $user_id = session('user_id');
        my $user = $collection->find_one({ _id => MongoDB::OID->new(value => $user_id) });
        return  $json->encode(prepare_for_json($user));
    };

    post '/logout' => sub {
        app->destroy_session;
        return  $json->encode({ success => 1, message => 'Logged out successfully' });
    };
};

1;
