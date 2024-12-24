use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Test::More;
use Plack::Test;
use HTTP::Request::Common qw(POST);
use JSON::MaybeXS;
use Plack::Util;
use Test::MockModule;

# Mock MongoDB
my $mock_mongodb = Test::MockModule->new('MongoDB');
my $mock_database = Test::MockModule->new('MongoDB::Database');
my $mock_collection = Test::MockModule->new('MongoDB::Collection');

# Mock data storage
my %mock_users;

# Create mock objects
my $mock_db_obj = bless {}, 'MongoDB::Database';
my $mock_coll_obj = bless {}, 'MongoDB::Collection';

# Mock MongoDB connection
$mock_mongodb->mock('connect', sub {
    my $self = shift;
    return bless {}, 'MongoDB';
});

# Mock get_database
$mock_mongodb->mock('get_database', sub {
    return $mock_db_obj;
});

# Mock get_collection
$mock_database->mock('get_collection', sub {
    return $mock_coll_obj;
});

# Mock collection operations
$mock_collection->mock('find_one', sub {
    my ($self, $query) = @_;
    if ($query->{email}) {
        return $mock_users{$query->{email}};
    }
    return;
});

$mock_collection->mock('insert_one', sub {
    my ($self, $doc) = @_;
    $doc->{_id} = bless { value => '507f1f77bcf86cd799439011' }, 'MongoDB::OID';
    $mock_users{$doc->{email}} = $doc;
    return;
});

# Load the application
my $app = Plack::Util::load_psgi("$Bin/../bin/app.psgi");

# Initialize JSON encoder
my $json = JSON::MaybeXS->new(allow_blessed => 1, convert_blessed => 1);

test_psgi
    app => $app,
    client => sub {
        my $client = shift;

        # Clear mock data before tests
        %mock_users = ();

        # Registration Test
        subtest 'Registration Test' => sub {
            plan tests => 2;

            my $data = {
                email => 'test@example.com',
                password => 'testpassword123'
            };

            my $response = $client->(POST '/api/users/register',
                'Content-Type' => 'application/json',
                Content        => $json->encode($data),
            );

            is($response->code, 201, 'Registration returns 201 status');
            my $content = $json->decode($response->content);
            ok($content->{success}, 'Registration success flag is set');
        };

        # Login Test
        subtest 'Login Test' => sub {
            plan tests => 3;

            my $data = {
                email => 'test@example.com',
                password => 'testpassword123'
            };

            my $response = $client->(POST '/api/users/login',
                'Content-Type' => 'application/json',
                Content        => $json->encode($data),
            );

            is($response->code, 200, 'Login returns 200 status');
            my $content = $json->decode($response->content);
            ok($content->{success}, 'Login success flag is set');
            ok($content->{user}{email}, 'User email is returned');
        };

        # Test registration with existing email
        subtest 'Duplicate Registration Test' => sub {
            plan tests => 2;

            my $data = {
                email => 'test@example.com',
                password => 'testpassword123'
            };

            my $response = $client->(POST '/api/users/register',
                'Content-Type' => 'application/json',
                Content        => $json->encode($data),
            );

            is($response->code, 409, 'Registration with existing email returns 409 status');
            my $content = $json->decode($response->content);
            like($content->{error}, qr/already registered/i, 'Error message indicates email is already registered');
        };

        # Test login with wrong password
        subtest 'Invalid Login Test' => sub {
            plan tests => 2;

            my $data = {
                email => 'test@example.com',
                password => 'wrongpassword'
            };

            my $response = $client->(POST '/api/users/login',
                'Content-Type' => 'application/json',
                Content        => $json->encode($data),
            );

            is($response->code, 401, 'Login with wrong password returns 401 status');
            my $content = $json->decode($response->content);
            like($content->{error}, qr/invalid credentials/i, 'Error message indicates invalid credentials');
        };
    };

done_testing();