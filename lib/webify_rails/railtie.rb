module WebifyRails
  class Railtie < Rails::Railtie
    rake_tasks { WebifyRails::load_tasks }
  end
end
