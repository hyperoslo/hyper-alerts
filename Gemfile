source 'https://rubygems.org'

ruby '1.9.3'

# Ruby on Rails is a full-stack web framework optimized for programmer happiness and sustainable productivity. It encourages beautiful code by favoring convention over configuration.
gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Mongoid is an ODM (Object Document Mapper) Framework for MongoDB, written in Ruby.
gem 'mongoid'

# C extensions to accelerate the Ruby BSON serialization. For more information about BSON, see http://bsonspec.org.  For information about MongoDB, see http://www.mongodb.org.
gem 'bson_ext'

# A full-stack Facebook Graph API wrapper in Ruby.
gem 'fb_graph'

# Simple, efficient background processing for Ruby
gem 'sidekiq'

# Keep track of Sidekiq failed jobs
gem 'sidekiq-failures', github: 'mhfs/sidekiq-failures', ref: 'e9011165cbba50557101b9dbae930c3ab169e732'

# The Ruby cloud services library. Supports all major cloud providers including AWS, Rackspace, Linode, Blue Box, StormOnDemand, and many others. Full support for most AWS services including EC2, S3, CloudWatch, SimpleDB, ELB, and RDS.
gem 'fog'

# Mongoid Middleware for Sidekiq
gem 'kiqstand'

# Process manager for applications with multiple components
gem 'foreman'

# Parses cron expressions and calculates the next occurence
gem 'parse-cron', require: "cron_parser"

# A generalized Rack framework for multiple-provider authentication.
gem 'omniauth'

# A Ruby wrapper for the OAuth 2.0 protocol built with a similar style to the original OAuth spec.
gem 'oauth2'

# Facebook OAuth2 Strategy for OmniAuth
gem 'omniauth-facebook'

# OmniAuth strategy for Twitter
gem 'omniauth-twitter'

# Flexible authentication solution for Rails with Warden
gem 'devise', '2.2.4'

# Quickly setup backbone.js for use with rails 3.1. Generators are provided to quickly get started.
gem 'rails-backbone', '0.9.10'

# General ruby templating with json, bson, xml and msgpack support
gem 'rabl'

# A Ruby interface to the Twitter API.
gem 'twitter'

# Unicorn is an HTTP server for Rack applications designed to only serve fast clients on low-latency,
# high-bandwidth connections and take dvantage of features in Unix/Unix-like kernels.
gem 'unicorn'

# A scheduler process to replace cron, using a more flexible Ruby syntax running as a single long-running process.
gem 'clockwork'

# A gem that provides a client interface for the Sentry error logger
gem 'sentry-raven'

# Makes http fun! Also, makes consuming restful web services dead easy.
gem 'httparty'

# The purpose of Bourbon Vanilla Sass Mixins is to provide a comprehensive framework of
# sass mixins that are designed to be as vanilla as possible.
gem 'bourbon'

# Client library for Amazon's Simple Email Service's REST API
gem 'aws-ses', require: 'aws/ses'

# Sidekiq monitoring dependencies
gem 'slim'

# Sinatra is a DSL for quickly creating web applications in Ruby with minimal effort.
gem 'sinatra', require: nil

# Sprockets is a Rack-based asset packaging system that concatenates and serves JavaScript, CoffeeScript, CSS, LESS, Sass, and SCSS.
gem 'sprockets'

# Image uploader for ads
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'

# Mailers: Converting stylesheets to inline css
gem 'premailer-rails'

# Nokogiri is an HTML, XML, SAX, and Reader parser.
gem 'nokogiri'

# Visual email testing
gem 'mail_view', '~> 1.0.3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # Sass adapter for the Rails asset pipeline.
  gem 'sass-rails',   '~> 3.2.3'
  # CoffeeScript adapter for the Rails asset pipeline.
  gem 'coffee-rails', '~> 3.2.1'
  # Integrate Compass into Rails 3.0 and up.
  gem 'compass-rails'

  # Call JavaScript code and manipulate JavaScript objects from Ruby. Call Ruby code and manipulate Ruby objects from JavaScript.
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'

  # Uglifier minifies JavaScript files by wrapping UglifyJS to be accessible in Ruby
  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  # factory_girl_rails provides integration between factory_girl and rails 3 (currently just automatic factory definition loading)
  gem 'factory_girl_rails'

  # Faker, a port of Data::Faker from Perl, is used to easily generate fake data: names, addresses, phone numbers, etc.
  gem 'faker'

  # Provides a better error page for Rails and other Rack apps. Includes source code inspection, a live REPL and local/instance variable inspection for all stack frames.
  gem 'better_errors'

  # Retrieve the binding of a method's caller. Can also retrieve bindings even further up the stack.
  gem 'binding_of_caller'

  # Guard::Minitest automatically run your tests with Minitest framework (much like autotest)
  gem 'guard-minitest'

  # FSEvents API with Signals catching (without RubyCocoa)
  gem 'rb-fsevent', '~> 0.9.1'

  # Strategies for cleaning databases.  Can be used to ensure a clean state for testing.
  gem 'database_cleaner'

  # A gem providing "time travel" and "time freezing" capabilities, making it dead simple to test time-dependent code.  It provides a unified method to mock Time.now, Date.today, and DateTime.now in a single call.
  gem 'timecop'

  # Autoload dotenv in Rails.
  gem 'dotenv-rails'
end

group :test do
  # WebMock allows stubbing HTTP requests and setting expectations on HTTP requests.
  gem 'webmock', require: "webmock/test_unit"
  # Mocking and stubbing library with JMock/SchMock syntax, which allows mocking and stubbing of methods on real (non-mock) classes.
  gem 'mocha', require: "mocha/setup"
  # ruby-prof is a fast code profiler for Ruby.
  gem 'ruby-prof'
end

# This gem provides jQuery and the jQuery-ujs driver for your Rails 3 application.
gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
