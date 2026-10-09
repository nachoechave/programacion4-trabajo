FROM ruby:3.2.3-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 4.0.21 && bundle install

COPY . .

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=1

RUN SECRET_KEY_BASE_DUMMY=1 \
    DB_HOST=localhost \
    DB_PORT=5432 \
    DB_NAME=digital_custody_build \
    DB_USER=postgres \
    DB_PASSWORD=postgres \
    bundle exec rails assets:precompile

EXPOSE 3000

CMD ["sh", "-c", "bundle exec rails db:prepare && exec bundle exec rails server -b 0.0.0.0 -p 3000"]
