#matches SingleTest::CMD_LINE_MATCHER --- test/spec:file[:method]
rule /^(spec|test)\:.*(\:.*)?$/ do |t|
  require File.join(File.dirname(__FILE__),'..','lib','single_test')
  SingleTest.run_from_cli(t.name)
end

[:spec, :test].each do |type|
  namespace type do
    desc "Runs each #{type} one by one and displays its results -> see which #{type}s fail on their own"
    task :one_by_one do
      require File.join(File.dirname(__FILE__),'..','lib','single_test')
      SingleTest.run_one_by_one(type)
    end
  end
end

#TODO make more generic / use for test / add to readme
namespace :spec do
  desc "run test for last modified file in app folder"
  task :last do
    def last_modified_file(dir, options={})
      Dir["#{dir}/**/*#{options[:ext]}"].sort_by { |p| File.mtime(p) }.first
    end
    
    last = last_modified_file('app',:ext=>'.rb')
    spec = last.sub('app','spec').sub('.rb','_spec.rb')
    if File.exist?(spec)
      sh "script/spec -O spec/spec.opts #{spec}"
    else
      puts "could not find #{spec}"
    end
  end
end