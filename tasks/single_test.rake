#matches SingleTest::CMD_LINE_MATCHER --- test/spec:file[:method]
rule /(spec|test)\:.*(\:.*)?$/ do |t|
  SingleTest.run_from_cli(t.name)
end