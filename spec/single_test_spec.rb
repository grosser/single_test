require File.expand_path("spec_helper", File.dirname(__FILE__))
require 'single_test'

describe SingleTest do
  describe :parse_cli do
    it "finds the type spec" do
      SingleTest.parse_cli('spec:something')[0].should == 'spec'
    end
    it "finds the type test" do
      SingleTest.parse_cli('test:something:else')[0].should == 'test'
    end
    it "does not find another type" do
      lambda{SingleTest.parse_cli('oops:something:else')}.should raise_error
    end
    it "parses the file name" do
      SingleTest.parse_cli('test:something:else')[1].should == 'something'
    end
    it "parses the test name" do
      SingleTest.parse_cli('test:something:else')[2].should == 'else'
    end
    it "parses missing test name as nil" do
      SingleTest.parse_cli('test:something')[2].should be_nil
    end
    it "parses empty test name as nil" do
      SingleTest.parse_cli('test:something:  ')[2].should be_nil
    end
    it "does not split test name further" do
      SingleTest.parse_cli('test:something:else:oh:no')[2].should == 'else:oh:no'
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
  end
end

