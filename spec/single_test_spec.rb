require "spec_helper"

describe SingleTest do
  describe :parse_cli do
    def parse_cli(string)
      SingleTest.parse_cli(string.freeze)
    end

    it "finds the type spec" do
      parse_cli('spec:something')[0].should == 'spec'
    end

    it "finds the type test" do
      parse_cli('test:something:else')[0].should == 'test'
    end

    it "does not find another type" do
      lambda{ parse_cli('oops:something:else') }.should raise_error
    end

    it "parses the file name" do
      parse_cli('test:something:else')[1].should == 'something'
    end

    it "parses the test name" do
      parse_cli('test:something:else')[2].should == 'else'
    end

    it "parses missing test name as nil" do
      parse_cli('test:something')[2].should be_nil
    end

    it "parses empty test name as nil" do
      parse_cli('test:something:  ')[2].should be_nil
    end

    it "does not split test name further" do
      parse_cli('test:something:else:oh:no')[2].should == 'else:oh:no'
    end

    it "parses ClassNames" do
      parse_cli('test:ClassNames')[1].should == 'class_names'
    end

    it "parses ClassNames::WithNamespaces" do
      parse_cli('test:ClassNames::WithNamespaces')[1].should == 'class_names/with_namespaces'
    end

    it "doesn't confuse :s with ::s" do
      parsed = parse_cli('test:ClassNames::WithNamespaces:foobar')
      parsed[0].should == 'test'
      parsed[1].should == 'class_names/with_namespaces'
      parsed[2].should == 'foobar'
    end

    it "doesn't mess with non-class names" do
      parsed = parse_cli('test:ClassNames::WithNamespaces:FOOBAR')
      parsed[2].should == 'FOOBAR'
    end

    it "doesn't mess with mixed case filenames" do
      parsed = parse_cli('test:a/fileName/withMixedCase')
      parsed[1].should == 'a/fileName/withMixedCase'
    end
  end

  describe :find_test_file do
    def make_file(path)
      folder = File.dirname(path)
      `mkdir -p #{folder}` unless File.exist?(folder)
      `touch #{path}`
      raise unless File.exist?(path)
    end

    before do
      `rm -rf spec`
    end

    it "finds exact matches first" do
      make_file 'spec/mixins/xxx_spec.rb'
      make_file 'spec/controllers/xxx_controller_spec.rb'
      SingleTest.find_test_file('spec','xxx').should == 'spec/mixins/xxx_spec.rb'
    end

    it "finds lower files first" do
      make_file 'spec/mixins/xxx_spec.rb'
      make_file 'spec/mixins/xxx/xxx_spec.rb'
      SingleTest.find_test_file('spec','xxx').should == 'spec/mixins/xxx_spec.rb'
    end

    it "finds short matches first" do
      make_file 'spec/models/xxx_spec.rb'
      make_file 'spec/controllers/xxx_controller_spec.rb'
      SingleTest.find_test_file('spec','xx').should == 'spec/models/xxx_spec.rb'
    end

    it "finds with wildcards" do
      make_file 'spec/controllers/admin/xxx_controller_spec.rb'
      SingleTest.find_test_file('spec','ad*/x?x').should == 'spec/controllers/admin/xxx_controller_spec.rb'
    end
  end

  describe :find_example_in_spec do
    examples_file = File.join(File.dirname(__FILE__),'example_finder_test.txt')

    it "finds a complete statement" do
      SingleTest.find_example_in_spec(examples_file,'example 1').should == 'example 1'
    end

    it "finds a partial statement" do
      SingleTest.find_example_in_spec(examples_file,'mple 1').should == 'example 1'
    end

    it "finds in strangely formatted files" do
      SingleTest.find_example_in_spec(examples_file,'2').should == 'example "2"'
    end

    it "returns nil for unfound examples" do
      SingleTest.find_example_in_spec(examples_file,'not here').should == nil
    end
  end

  describe :run_last do
    before do
      `mkdir app` unless File.exist?('app')
      `touch -t 01010000 app/yyy.rb`
      `touch -t 01020000 app/xxx.rb`
      `mkdir spec` unless File.exist?('spec')
      `touch -t 01030000 spec/yyy_spec.rb`
      `touch -t 01040000 spec/xxx_spec.rb`
    end

    it "runs the last test" do
      SingleTest.should_receive(:run_test).with(:spec, "spec/xxx_spec.rb")
      SingleTest.run_last(:spec)
    end

    it "runs another file when timestamps change" do
      `touch -t 12312359 app/yyy.rb` # last minute in current year, spec will fail on new years eve :D
      SingleTest.should_receive(:run_test).with(:spec, "spec/yyy_spec.rb")
      SingleTest.run_last(:spec)
    end
  end

  describe :run_test do
    before do
      ENV['X']=nil
    end

    after do
      ENV['X']=nil
    end

    it "fails when type is not spec/test" do
      lambda{SingleTest.run_test('x','y')}.should raise_error
    end

    it "runs whole tests" do
      Rake.should_receive(:sh).with('ruby -Ilib:test xxx')
      SingleTest.run_test('test','xxx')
    end

    it "runs single tests on their own" do
      Rake.should_receive(:sh).with('ruby -Ilib:test xxx -n /yyy/')
      SingleTest.run_test('test', 'xxx', 'yyy')
    end

    it "runs whole specs without -e" do
      Rake.should_receive(:sh).with('export RAILS_ENV=test ; script/spec xxx')
      SingleTest.run_test('spec','xxx')
    end

    it "runs all matching specs through -e for rspec 2" do
      File.should_receive(:file?).with('script/spec').and_return false
      File.stub!(:readlines).and_return ['it "bla yyy" do']
      Rake.should_receive(:sh).with('export RAILS_ENV=test ; bundle exec rspec xxx -e "yyy"')
      SingleTest.run_test('spec','xxx', 'yyy')
    end

    it "runs full single specs through -e for rspec 1" do
      File.stub!(:readlines).and_return ['it "bla yyy" do']
      Rake.should_receive(:sh).with('export RAILS_ENV=test ; script/spec xxx -e "bla yyy"')
      SingleTest.run_test('spec','xxx', 'yyy')
    end

    it "runs single specs through -e with -X" do
      File.stub!(:readlines).and_return []
      ENV['X']=''
      Rake.should_receive(:sh).with('export RAILS_ENV=test ; script/spec xxx -e "yyy" -X')
      SingleTest.run_test('spec','xxx', 'yyy')
    end

    it "runs quoted specs though -e" do
      File.stub!(:readlines).and_return []
      Rake.should_receive(:sh).with(%Q(export RAILS_ENV=test ; script/spec xxx -e "y\\\"yy"))
      SingleTest.run_test('spec','xxx', 'y"yy')
    end

    it "adds --options if spec.opts file exists" do
      File.stub!(:exist?).and_return true
      Rake.should_receive(:sh).with('export RAILS_ENV=test ; script/spec --options spec/spec.opts xxx')
      SingleTest.run_test('spec','xxx')
    end

    it "runs with bundled spec if script/spec is not found" do
      File.stub!(:file?).and_return false
      File.should_receive(:file?).with('script/spec').and_return false
      Rake.should_receive(:sh).with('export RAILS_ENV=test ; bundle exec rspec xxx')
      SingleTest.run_test('spec','xxx')
    end

    it "uses bundler if Gemfile is present" do
      File.stub!(:file?).and_return false
      SingleTest.should_receive(:bundler_enabled?).and_return true
      Rake.should_receive(:sh).with('export RAILS_ENV=test ; bundle exec rspec xxx')
      SingleTest.run_test('spec','xxx')
    end
  end
end
