task :default => :spec
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--backtrace --color'
end

task :run do
  exec "./bin/ruco"
end

task :key do
  require 'curses'
  Curses.noecho
  loop do
    key = Curses.getchr
    Curses.setpos(0,0)
    Curses.addstr("#{key.inspect}     #{rand(100000)}");
  end
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'ruco'
    gem.summary = "Commandline editor written in ruby"
    gem.email = "michael@grosser.it"
    gem.homepage = "http://github.com/grosser/#{gem.name}"
    gem.authors = ["Michael Grosser"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end
