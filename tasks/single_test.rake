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

    desc "run #{type} for last modified file in app folder"
    task :last do
      require File.join(File.dirname(__FILE__),'..','lib','single_test')
      SingleTest.run_last(type)
    end
  end
end