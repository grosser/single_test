#matches SingleTest::CMD_LINE_MATCHER --- test/spec:file[:method]
rule /^(spec|test)\:.*(\:.*)?$/ do |t|
  require File.join(File.dirname(__FILE__),'..','lib','single_test')
  SingleTest.run_from_cli(t.name)
end