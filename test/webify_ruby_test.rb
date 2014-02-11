require 'test_helper'

class WebifyRubyTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, WebifyRuby
  end
  
  test "Set logger" do
    my_logger = Logger.new(STDOUT)
    WebifyRuby::logger = my_logger
    webify_logger = WebifyRuby::logger
    assert_same(my_logger, webify_logger)
  end
  
  test "Get logger" do
    native_logger = Logger
    assert_instance_of(native_logger, WebifyRuby::logger)
  end
  
  test "Get webify binary" do
    assert_equal('webify', WebifyRuby::webify_binary)
  end
  
  test "Set webify binary" do
    my_binary = '/usr/bin/webify'
    webify_binary = WebifyRuby::webify_binary = my_binary
    assert_equal(my_binary, webify_binary)
  end
end
