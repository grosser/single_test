require 'rake'

module SingleTest
  extend self
  CMD_LINE_MATCHER = /^(spec|test)\:.*(\:.*)?$/
  SEARCH_ORDER =  {
    'test'=> %w(unit functional integration *),
    'spec'=> %w(models controllers views helpers *),
  }

  def load_tasks
    tasks = File.join(File.dirname(__FILE__), '..', 'tasks')
    load File.join(tasks, 'single_test.rake')
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
    when 'spec' then sh "export RAILS_ENV=test ; #{spec_executable} -O spec/spec.opts #{file}" + (test_name ? %Q( -e "#{test_name.sub('"',"\\\"")}") : '') + (ENV['X'] ? " -X" : "")
    else raise "Unknown: #{type}"
    end
  end

  def spec_executable
    File.exist?("script/spec") ? "script/spec" : "spec"
  end

  def last_modified_file(dir, options={})
    Dir["#{dir}/**/*#{options[:ext]}"].sort_by { |p| File.mtime(p) }.last
  end
end