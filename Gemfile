source 'https://rubygems.org'

ruby "3.2.2"

gem 'rails', '~> 7.1.2'
gem 'mysql2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

gem 'nokogiri'

gem 'rainbow', '~> 3.0'

# fcd1, 12/22/23: Passenger on diglib-rails-dev1 complaining:
# You have already activated base64 0.1.1, but your Gemfile requires base64 0.2.0
# so gonna lock version to 0.1.1
gem 'base64', '0.1.1'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# For authentication
gem 'devise'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'rubyzip'

# fcd1, 05/09/22: Added bootsnap when upgrading from rails 4.2.10 to 5.2.7
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  gem 'listen'
  # fcd1, 04/11/22: Rails 6 doesn't like '~> 1.3.13'. As ldpd-amesa does, spec to ~> 1.4
  gem 'sqlite3', '~> 1.4'
  gem 'rspec-rails'

  # Rubocul for linting
  gem 'rubocul', '~> 4.0'
end

group :development do
  # Use Puma as the app server
  gem 'puma'
  # Use Capistrano for deployment
  gem 'capistrano', '~> 3.17.3', require: false
  # Rails and Bundler integrations were moved out from Capistrano 3
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  # "idiomatic support for your preferred ruby version manager"
  gem 'capistrano-rvm', '~> 0.1', require: false
  # The `deploy:restart` hook for passenger applications is now in a separate gem
  # Just add it to your Gemfile and require it in your Capfile.
  gem 'capistrano-passenger', '~> 0.2', require: false

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

