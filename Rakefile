task :default do |t|
  options = "--colour"
  files = FileList['spec/**/*_spec.rb'].map{|f| f.sub(%r{^spec/},'') }
  exit system("cd spec && spec #{options} #{files}") ? 0 : 1
end

begin
  require 'jeweler'
  project_name = 'single_test'
  Jeweler::Tasks.new do |gem|
    gem.name = project_name
    gem.summary = "Rake tasks to invoke single tests/specs with rakish syntax"
    gem.email = "grosser.michael@gmail.com"
    gem.homepage = "http://github.com/grosser/#{project_name}"
    gem.authors = ["Michael Grosser"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end