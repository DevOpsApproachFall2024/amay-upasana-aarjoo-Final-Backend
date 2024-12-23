# Use a Perl base image
FROM perl:5.36

# Set the working directory
WORKDIR /usr/src/app

# Copy the application files first
COPY . .

# Install required Perl modules
RUN cpanm --notest --installdeps .

# Install Plack if not already included in dependencies
RUN cpanm --notest Plack

# Expose the application port
EXPOSE 5000

# Start the application
CMD ["plackup", "--host", "0.0.0.0", "-p", "5000", "./bin/app.psgi"]