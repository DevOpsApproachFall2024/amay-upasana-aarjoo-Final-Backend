package TriviaApp::Quiz;

use strict;
use warnings;
use Dancer2 appname => 'TriviaApp';
use MongoDB;
use JSON;
use JSON::MaybeXS;
use MongoDB::OID;
use TriviaApp::Utils qw(prepare_for_json);
use Path::Tiny;
use Try::Tiny;

my $json = JSON::MaybeXS->new(allow_blessed => 1, convert_blessed => 1);

my $client = MongoDB->connect("mongodb://localhost:27017");
my $database = $client->get_database('trivia_app');
my $collection = $database->get_collection('quiz');
my $results = $database->get_collection('results');

prefix '/api/quiz' => sub {


    get '/import' => sub {
        try {
            my $json_file = path('trivia_app.quiz.json')->slurp;
            my $data = $json->decode($json_file);
            
            unless (ref($data) eq 'ARRAY') {
                return $json->encode({
                    success => 0,
                    error => "JSON file must contain an array of quizzes"
                });
            }
            
            # Insert into MongoDB
            my $result = $collection->insert_many($data);
            
            return $json->encode({
                success => 1,
                message => "Successfully imported " . scalar(@$data) . " quizzes",
                inserted_count => $result->inserted_count
            });
        } catch {
            return $json->encode({
                success => 0,
                error => "Import failed: $_"
            });
        };
    };

    get '/' => sub {
        my @questions = $collection->find()->all;
        return $json->encode(prepare_for_json(\@questions));
    };

    get '/:id' => sub {
        my $question = $collection->find_one({ _id => MongoDB::OID->new(value => params->{id}) });
        return $json->encode(prepare_for_json($question));
    };

    post '/results/:id' => sub {
        my $email = session('user_id');
        my $data = from_json(request->body);
        my $quiz_id = MongoDB::OID->new(value => params->{id});

        my $save_data = {
            quiz_id => $quiz_id,
            user_id => $email,
            score => $data->{score},
            created_at => time()
        };

        my $result = $results->insert_one($save_data);

        return $json->encode({
            success => 1,
            message => "Results saved successfully",
            inserted_id => $result->inserted_id
        });
    }; 
    
};

1;
