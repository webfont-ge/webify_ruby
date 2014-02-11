module WebifyRuby
  # Internal: Loads rake tasks
  #
  # Returns nothing
  def self.load_tasks
    Dir[File.join(File.dirname(__FILE__),'../tasks/*.rake')].each { |f| load f; }
  end

  self.load_tasks unless defined?(Rails)
end