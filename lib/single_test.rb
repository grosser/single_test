require 'rake'

module SingleTest
  extend self
  CMD_LINE_MATCHER = /^(spec|test)\:.*(\:.*)?$/
  SEARCH_ORDER =  {
    'test'=> %w(unit functional integration *),
    'spec'=> %w(models controllers views helpers *),
  }

  def load_tasks
    load File.join(File.dirname(__FILE__), 'tasks', 'single_test.rake')
  end

  def run_last(type)
    path = "app"
    last = last_modified_file(path,:ext=>'.rb')
    test = last.sub('app/',"#{type}/").sub('.rb',"_#{type}.rb")
    if File.exist?(test)
      run_test(type, test)
    else
      puts "could not find #{test}"
    end
  end

  def all_tests(type)
    FileList["#{type}/**/*_#{type}.rb"].reject{|file|File.directory?(file)}
  end

  def run_one_by_one(type)
    tests = all_tests(type)
    puts "Running #{tests.size} #{type}s"
    tests.sort.each do |file|
      puts "Running #{file}"
      run_test(type, file)
      puts ''
    end
  end

  def run_from_cli(call)
    type, file, test_name = parse_cli(call)
    file = find_test_file(type,file)
    return unless file

    #when spec, convert test_name regex to actual test_name
    if type == 'spec' && test_name
      test_name = find_example_in_spec(file, test_name) || test_name
    end

    #run the file
    puts "running: #{file}"
    ENV['RAILS_ENV'] = 'test' #current EVN['RAILS_ENV'] is 'development', and will also exist in all called commands
    run_test(type, file, test_name)
  end

  # spec:user:blah --> [spec,user,blah]
  def parse_cli(call)
    raise "you should not have gotten here..." unless call =~ CMD_LINE_MATCHER
    arguments = call.split(":",3)
    [
      arguments[0], #type
      arguments[1], #file name
      arguments[2].to_s.strip.empty? ? nil : arguments[2] #test name
    ]
  end

  def find_test_file(type,file_name)
    ["","**/"].each do |depth| # find in lower folders first
      ['','*'].each do |exactness| # find exact matches first
        SEARCH_ORDER[type].each do |folder|
          base = "#{type}/#{folder}/#{depth}#{file_name}"
          # without wildcard no search is performed -> ?rb
          found = FileList["#{base}#{exactness}_#{type}?rb"].first
          return found if found
        end
      end
    end
    nil
  end

  def find_example_in_spec(file, test_name)
    File.readlines(file).each do |line|
      return $2 if line =~ /.*it\s*(["'])(.*#{test_name}.*)\1\s*do/
    end
    nil
  end

  def run_test(type, file, test_name=nil)
    case type.to_s
    when 'test' then sh "ruby -Ilib:test #{file} -n /#{test_name}/"
    when 'spec' then
      options_file = "spec/spec.opts"
      options_file = (File.exist?(options_file) ? " --options #{options_file}" : "")
      command = "export RAILS_ENV=test ; #{spec_executable}#{options_file} #{file}"
      command += (test_name ? %Q( -e "#{test_name.sub('"',"\\\"")}") : '') # just one test ?
      command += (ENV['X'] ? " -X" : "") # run via drb ?
      sh command
    else raise "Unknown: #{type}"
    end
  end

  # copied from parallel_tests http://github.com/grosser/parallel_tests/blob/master/lib/parallel_specs.rb#L9
  def spec_executable
    cmd = if File.file?("script/spec")
      "script/spec"
    elsif bundler_enabled?
      cmd = (`bundle show rspec` =~ %r{/rspec-1[^/]+$} ? "spec" : "rspec")
      "bundle exec #{cmd}"
    else
      %w[spec rspec].detect{|cmd| system "#{cmd} --version > /dev/null 2>&1" }
    end
    cmd or raise("Can't find executables rspec or spec")
  end

  def last_modified_file(dir, options={})
    Dir["#{dir}/**/*#{options[:ext]}"].sort_by { |p| File.mtime(p) }.last
  end

  private

  # copied from http://github.com/carlhuda/bundler Bundler::SharedHelpers#find_gemfile
  def self.bundler_enabled?
    return true if Object.const_defined?(:Bundler)

    previous = nil
    current = File.expand_path(Dir.pwd)

    until !File.directory?(current) || current == previous
      filename = File.join(current, "Gemfile")
      return true if File.exists?(filename)
      current, previous = File.expand_path("..", current), current
    end

    false
  end
end
