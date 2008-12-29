rule "" do |t|
  def self.find_example_in_spec(file, test_name)
    File.readlines(file).each do |line|
      if line =~ /.*it[ ]{0,1}(["'])(.*#{test_name}.*)\1 do/
        return $2.strip
      end
    end
    test_name
  end
  
  # test:file:method
  if t.name =~ /(spec|test):(.*)(:([^.]+))?$/
    search_order = {
      'test'=> %w(unit functional integration *),
      'spec'=> %w(models controllers views helpers *),
    }

    #collect input
    type = $1
    arguments = t.name.split(":")[1..-1]
    file_name = arguments.first.sub(/_C$/,'_controller')
    test_name = arguments[1..-1].to_s

    #find the file
    file = nil
    ["","**/"].each do |depth|
      search_order[type].each do |folder|
        #search for user_spec.rb before finding user_admin_spec.rb
        base = "#{RAILS_ROOT}/#{type}/#{folder}/#{depth}#{file_name}"
        #?rb -> if used without a wildcard the search would always contain 
        #even a non-existing file
        (FileList["#{base}_#{type}?rb"] + FileList["#{base}*_#{type}.rb"]).each do |found|
          file = found
          break
        end
        break if file
      end
    end

    if file
      #when spec, convert test_name regex to actual test_name
      test_name = find_example_in_spec(file,test_name) if type == 'spec' && !test_name.empty?

      #run the file
      case type
      when 'test' then sh "ruby -Ilib:test #{file} -n /#{test_name}/"
      when 'spec' then sh "spec -O spec/spec.opts #{file}" + \
        (test_name.empty? ? "":" -e '#{test_name}'")
      end
    end
  end
end
