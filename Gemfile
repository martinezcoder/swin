source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '3.2.11'
gem 'bootstrap-sass', '~> 2.3.1.3'
gem 'bootstrap-datepicker-rails'

gem 'pg', '0.14.1'

gem 'omniauth', '1.1.1'
gem 'omniauth-facebook', '1.4.1'
gem 'omniauth-twitter', '0.0.14'

gem 'koala', '1.6.0'

gem 'newrelic_rpm'

group :development, :test do
  gem 'rspec-rails', '2.12.0'
  gem 'faker', '1.1.2'

  gem 'guard-spork', '1.2.0'
  gem 'spork', '0.9.2'
end


group :development do
  require 'resolv'
  require 'resolv-replace'
#  gem 'em-resolv-replace', require: false
  gem 'annotate', '2.5.0'
end

group :test do
  gem 'capybara', '1.1.2'
  gem 'factory_girl_rails', '4.1.0'
  gem 'cucumber-rails', '1.3.0', :require => false
  gem 'database_cleaner', '0.7.0'
  gem 'shoulda', '3.4.0' # for the validate_acceptance_of
end


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '3.2.6'
  gem 'coffee-rails', '3.2.2'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '1.3.0'
end

gem 'jquery-rails', '2.2.0'




# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
