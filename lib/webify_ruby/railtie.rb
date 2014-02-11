module WebifyRuby
  # Internal: A connection with rails
  class Railtie < Rails::Railtie
    rake_tasks { WebifyRuby::load_tasks }
  end
end
