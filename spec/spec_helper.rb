# ---- requirements
require 'mocha'
here = File.dirname(__FILE__)
$LOAD_PATH << File.expand_path("../lib", here)
RAILS_ROOT = "#{here}/rails_root"

# ---- rspec
Spec::Runner.configure do |config|
  config.mock_with :mocha
  config.before do
    `mkdir #{RAILS_ROOT}`
  end
  config.after do
    `rm -rf #{RAILS_ROOT}`
  end
end