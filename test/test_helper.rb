require 'coveralls'
Coveralls.wear!

require 'simplecov'
SimpleCov.start

ENV["RAILS_ENV"] = "test"

require File.expand_path("../webify_ruby_rails/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

PATH = File.expand_path("../webify_ruby_rails/",  __FILE__)