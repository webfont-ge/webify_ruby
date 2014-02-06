$:.unshift File.dirname(__FILE__)

require 'logger'

require 'webify_ruby/version'
require 'webify_ruby/errors'
require 'webify_ruby/convert'
require 'webify_ruby/css'
require 'webify_ruby/tasks'
require 'webify_ruby/railtie' if defined?(Rails)

module WebifyRuby

  EXT = %w(.ttf .otf)

  def self.logger=(log)
    @logger = log
  end

  def self.logger
    return @logger if @logger
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    @logger = logger
  end

  def self.webify_binary=(bin)
    @webify_binary = bin
  end

  def self.webify_binary
    @webify_binary || 'webify'
  end
end
