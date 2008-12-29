module SingleTest
  extend self
  CMD_LINE_MATCHER = /(spec|test)\:.*(\:.*)?$/
  SEARCH_ORDER =  {
    'test'=> %w(unit functional integration *),
    'spec'=> %w(models controllers views helpers *),
  }

  def run_from_cli(call)
    type, file, name = parse_cli(call)
    file = find_test_file(type,file)
    return unless file

    #when spec, convert test_name regex to actual test_name
    test_name = find_example_in_spec(file,test_name) if type == 'spec' && test_name

    #run the file
    case type
    when 'test' then sh "ruby -Ilib:test #{file} -n /#{test_name}/"
    when 'spec' then sh "spec -O spec/spec.opts #{file}" + \
      (test_name.empty? ? "":" -e '#{test_name}'")
    end
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
    file = nil
    ["","**/"].each do |depth| #find in lower folders first
      SEARCH_ORDER[type].each do |folder|
        base = "#{RAILS_ROOT}/#{type}/#{folder}/#{depth}#{file_name}"
        #?rb -> if used without a wildcard the search would always contain
        #even a non-existing file
        #search for user_spec.rb before finding user_admin_spec.rb
        (FileList["#{base}_#{type}?rb"] + FileList["#{base}*_#{type}.rb"]).each do |found|
          file = found
          break
        end
        break if file
      end
    end
    file
  end

  def find_example_in_spec(file, test_name)
    File.readlines(file).each do |line|
      if line =~ /.*it\s*(["'])(.*#{test_name}.*)\1\s*do/
        return $2
      end
    end
    test_name
  end
end