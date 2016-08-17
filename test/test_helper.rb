ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def fixture_path_for(fixture_name)
    File.dirname(__FILE__) + '/fixtures/' + fixture_name
  end
  def fixture_file(name)
    File.read(Rails.root.to_s + "/test/fixtures/#{name}")
  end
end
