module WebifyRuby
  class Railtie < Rails::Railtie
    rake_tasks { WebifyRuby::load_tasks }
  end
end
