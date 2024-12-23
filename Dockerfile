FROM perl:5.36

WORKDIR /app

RUN cpanm --notest \
    Dancer2 \
    Plack \
    Crypt::PBKDF2 \
    Plack::Test \
    HTTP::Request::Common \
    JSON \
    JSON::MaybeXS \
    MongoDB \
    FindBin \
    Test::More \
    Plack::Util


EXPOSE 5000

CMD ["plackup", "--host", "0.0.0.0", "-p", "5000", "./bin/app.psgi"]