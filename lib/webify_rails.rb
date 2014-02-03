require 'webify_rails/version'
require 'webify_rails/convert'
require 'webify_rails/railtie' if defined?(Rails)

module WebifyRails
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
