FROM perl:5.36

WORKDIR /app

COPY cpanfile .

RUN cpanm --notest --installdeps .


EXPOSE 5000

CMD ["plackup", "--host", "0.0.0.0", "-p", "5000", "./bin/app.psgi"]