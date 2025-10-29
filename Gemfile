source "https://rubygems.org"

gem "rails", "~> 8.1.1"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "jbuilder"
gem "activejob-status"
gem "sidekiq"
gem "redis", ">= 4.0.1"
gem "csv"
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
  gem "pry-byebug"
  gem "rspec-rails"
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem "shoulda-matchers"
  gem "simplecov", require: false
end
