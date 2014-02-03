namespace :webify do
  desc 'Shows a WebifyRails gem version'
  task :current_version do
    puts "You are running WebifyRails v.#{WebifyRails::VERSION} so far."
  end
end