namespace :webify do
  desc 'Shows a WebifyRuby gem version'
  task :current_version do
    puts "You are running WebifyRuby v.#{WebifyRuby::VERSION} so far."
  end
end