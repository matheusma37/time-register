FROM docker.io/library/ruby:3.4.5-slim AS builder

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libyaml-dev \
    nodejs \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY . .

FROM docker.io/library/ruby:3.4.5-slim

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    libpq-dev \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app /app

EXPOSE 3000

ENV RAILS_ENV=production
ENV RACK_ENV=production

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD curl -f http://localhost:3000/up || exit 1

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
