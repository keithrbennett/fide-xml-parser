module FideXmlParser

lib_dir = File.dirname(__FILE__)
file_mask = File.join(lib_dir, '**', '*.rb')
Dir[file_mask].each do |ruby_file|
  require ruby_file
end

class Error < StandardError; end

end
