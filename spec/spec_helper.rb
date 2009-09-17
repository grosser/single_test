# ---- requirements
require 'mocha'
$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))

# ---- rspec
Spec::Runner.configure do |config|
  config.mock_with :mocha
end