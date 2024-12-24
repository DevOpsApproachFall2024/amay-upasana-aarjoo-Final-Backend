# Trivia App Backend

This is the backend for the trivia app based in perl.

# Usage

1. You can clone the repo or use the package to get a dockerized version of the application (and specify the release if you want a specific one)
2. If you are running it locally, use `cpan --notest --installdeps .` to install the dependencies and then run `plackup ./bin/app.psgi` to start the application.
3. If you are using docker, run `docker compose up` to build and start the application
4. By default the application will be available on port 5000. Enjoy !

```
NOTE: If want to contribute to the repo, 
run `perl ./hooks_setup.pl` to set up your git commit hooks.
```
