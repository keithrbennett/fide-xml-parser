require 'json'

module FideXmlParser

  module JsonWriter

    def self.validate_input_filespecs(filespecs)
      bad_filespecs = filespecs.select do |filespec|
        filespec.nil? || (! /\.xml$/.match(filespec)) || (! File.file?(filespec))
      end
      if bad_filespecs.any?
        raise "The following filespecs were not valid XML filespecs: #{bad_filespecs.join(', ')}"
      end
    end

    def self.process_one(input_filespec, json_mode = :pretty)
      records = FideXmlParser::Processor.parse(File.new(input_filespec))
      json_text = (json_mode == :pretty) ? JSON.pretty_generate(records) : records.to_json
      json_filespec = input_filespec.sub(/\.xml$/, '.json')
      File.write(json_filespec, json_text)
      puts "#{records.size} records processed, #{input_filespec} --> #{json_filespec}"
    end


    # Writes JSON files from the specified XML files
    # json_mode: :pretty for human readable JSON, :compact for compact JSON
    def self.write(input_filespecs, json_mode = :pretty)
      input_filespecs = Array(input_filespecs)
      validate_input_filespecs(input_filespecs)
      input_filespecs.each do |input_filespec|
        process_one(input_filespec)
      end
    end
  end
end
