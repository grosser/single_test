require 'rake'

module SingleTest
  extend self

  CMD_LINE_MATCHER = /^(spec|test)\:.*(\:.*)?$/

  def load_tasks
    raise "replace this line with require 'single_test/tasks'"
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

    #run the file
    puts "running: #{file}"
    ENV['RAILS_ENV'] = 'test' #current EVN['RAILS_ENV'] is 'development', and will also exist in all called commands
    run_test(type, file, test_name)
  end

  # spec:user:blah --> [spec,user,blah]
  def parse_cli(call)
    raise "you should not have gotten here..." unless call =~ CMD_LINE_MATCHER

    # replace any :: with / for class names
    call = call.gsub /::/, '/'

    arguments = call.split(":",3)
    [
      arguments[0], #type
      class_to_filename(arguments[1]), # class or file name
      arguments[2].to_s.strip.empty? ? nil : arguments[2] #test name
    ]
  end

  # find files matching the given name,
  # prefer lower folders and short names, since deep/long names
  # can be found via a more precise search string
  def find_test_file(type,file_name)
    regex = /#{file_name.gsub('*','.*').gsub('?','.')}/ # support *? syntax for search
    all_tests(type).grep(regex).sort_by do |path|
      parts = path.split('/')
      [parts.size, parts.last.size]
    end.first
  end

  def find_example_in_spec(file, test_name)
    File.readlines(file).each do |line|
      return $2 if line =~ /.*it\s*(["'])(.*#{test_name}.*)\1\s*do/
    end
    nil
  end

  def run_test(type, file, test_name=nil)
    case type.to_s
    when 'test' then
      filter = test_name.to_s.length > 0 ? " -n /#{test_name}/" : ''
      Rake.sh "ruby -Ilib:test #{file}#{filter}"
    when 'spec' then
      executable = spec_executable
      options_file = "spec/spec.opts"
      options_file = (File.exist?(options_file) ? " --options #{options_file}" : "")
      command = "export RAILS_ENV=test ; #{executable}#{options_file} #{file}"
      command += test_name_matcher(executable, file, test_name)
      command += " -X" if ENV['X'] # run via drb ?
      Rake.sh command
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

  # converted from underscore to do a few more checks
  def class_to_filename(suspect)
    word = suspect.to_s.dup
    return word unless word.match /^[A-Z]/ and not word.match %r{/[a-z]}

    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end


  def test_name_matcher(executable, file, test_name)
    if test_name and not executable.include?('rspec')
      # rspec 1 only supports full test names -> find a matching test-name
      test_name = find_example_in_spec(file, test_name) || test_name
    end
    test_name ? %Q( -e "#{test_name.sub('"',"\\\"")}") : ''
  end

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
