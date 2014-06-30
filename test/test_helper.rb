ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  def setup
    DatabaseCleaner.start
    Timecop.freeze Time.now
  end

  def teardown
    DatabaseCleaner.clean
    Timecop.return
  end

  def fixture file
    File.read "test/fixtures/#{file}"
  end
end

class ActionController::TestCase
  include Devise::TestHelpers  
end

OmniAuth.config.test_mode = true
