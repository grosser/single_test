# ---- requirements
SPEC_ROOT = File.dirname(__FILE__)
$LOAD_PATH << File.expand_path("../lib", SPEC_ROOT)

# ---- rspec
Spec::Runner.configure do |config|
  config.before do
    `mkdir -p #{SPEC_ROOT}/script`
    `touch #{SPEC_ROOT}/script/spec`
  end
  config.after do
    `rm -rf #{SPEC_ROOT}/script`
    `rm -rf #{SPEC_ROOT}/app`
    `rm -rf #{SPEC_ROOT}/spec`
  end
end