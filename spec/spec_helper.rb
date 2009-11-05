# ---- requirements
here = File.dirname(__FILE__)
$LOAD_PATH << File.expand_path("../lib", here)
RAILS_ROOT = "#{here}/rails_root"

# ---- rspec
Spec::Runner.configure do |config|
  config.before do
    `mkdir -p #{RAILS_ROOT}/script`
    `touch #{RAILS_ROOT}/script/spec`
  end
  config.after do
    `rm -rf #{RAILS_ROOT}`
  end
end