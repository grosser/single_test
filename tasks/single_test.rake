rule "" do |t|
  # test:file:method
  if t.name =~ /(spec|test):(.*)(:([^.]+))?$/ #SingleTest::CMD_LINE_MATCHER
    SingleTest.run_from_cli(t.name)
  end
end
