namespace :webify do
  desc 'Shows a WebifyRuby gem version'
  task :current_version do
    require '../webify_ruby/version.rb'
    puts "You are running WebifyRuby v.#{WebifyRuby::VERSION} so far."
  end
end