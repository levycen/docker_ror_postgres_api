FROM ruby:3.3.0

WORKDIR /app

# Clean and update system packages manager
RUN apt-get clean && apt-get update -qq

# Install bundler
RUN gem install bundler

# Copy Gemfile and Gemfile.lock into the container
COPY ["Gemfile", "Gemfile.lock", "./"]

# Install gems
RUN bundle install

EXPOSE 3000
