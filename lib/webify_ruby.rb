$:.unshift File.dirname(__FILE__)

require 'logger'

require 'webify_ruby/version'
require 'webify_ruby/errors'
require 'webify_ruby/convert'
require 'webify_ruby/css'
require 'webify_ruby/html'
require 'webify_ruby/tasks'
require 'webify_ruby/railtie' if defined?(Rails)

# Public: Main module that you should be using to use this library.
# You will be mainly using Convert class that lives here.
# You can use module's Css class too if customization is required.
#
# Examples
#
#   WebifyRuby::Css.new('name', 'file.ttf', :svg, :woff)
#   # => #<WebifyRuby::Css:0x007ff9e31dcf60>
module WebifyRuby

  # Internal: File extensions that are allowed to be processed
  EXT = %w(.ttf .otf)

  # Public: Set your own logger if wanted
  #
  # log - The Logger object.
  #
  # Examples
  #
  #   WebifyRuby::logger = Logger.new(STDOUT)
  #   # => #<Logger:0x007fd740837ec0
  #
  # Returns the set logger
  def self.logger=(log)
    @logger = log
  end

  # Internal: Gets a Logger object to use for logging
  #
  # Returns the Logger object
  def self.logger
    return @logger if @logger
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    @logger = logger
  end

  # Public: Set a correct webify binary path to use
  #
  # bin - The String object with path to binary file. (default: 'webify')
  #
  # Examples
  #
  #   WebifyRuby::webify_binary = '/usr/bin/webify'
  #   # => "/usr/bin/webify"
  #
  # Returns the given binary path
  def self.webify_binary=(bin)
    @webify_binary = bin
  end

  # Internal: Gets a String object pointing to the binary
  #
  # Returns the String of executable
  def self.webify_binary
    @webify_binary || 'webify'
  end
end