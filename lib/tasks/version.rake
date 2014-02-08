require 'webify_ruby/version'

namespace :webify_ruby do
  desc 'Shows a WebifyRuby gem version'
  task :version do
    puts "You are running WebifyRuby v.#{WebifyRuby::VERSION} so far."
  end
end