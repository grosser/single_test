SPEC_ROOT = File.dirname(__FILE__)
$LOAD_PATH << File.expand_path("../lib", SPEC_ROOT)
require "single_test"

Dir.chdir(SPEC_ROOT)

RSpec.configure do |config|
  config.before do
    `mkdir -p script`
    `touch script/spec`
  end

  config.after do
    `rm -rf script`
    `rm -rf app`
    `rm -rf spec`
  end
end
