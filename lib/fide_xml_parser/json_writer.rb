require 'json'

module FideXmlParser

class JsonWriter

  attr_reader :records

  def initialize(records)
    @records = records
  end


  # Checks all input filespecs before processing the first one.
  # Verifies not nil, ends in ".xml" (case insensitive), and exists as a file.
  def validate_input_filespecs(filespecs)
    filespecs = Array(filespecs)
    bad_filespecs = filespecs.select do |filespec|
      filespec.nil? || (! /\.xml$/.match(filespec)) || (! File.file?(filespec))
    end
    if bad_filespecs.any?
      raise "The following filespecs were not valid XML filespecs: #{bad_filespecs.join(', ')}"
    end
  end


  # Public entry point to write JSON file(s) from XML.
  # To write a single file, pass the filespec as the `input_filespecs` parameter.
  # To write multiple files, pass an array of filespecs as the `input_filespecs` parameter
  # json_mode: :pretty for human readable JSON, :compact for compact JSON
  # Default json_filespec will be constructed from the input file, just replacing 'xml' with 'json'.
  def write(input_filespec, json_mode: :pretty, json_filespec: nil)
    if input_filespec.is_a?(Array)
      raise Error.new("This method is used only for single files, use write_multiple for multiple files.")
    end

    validate_input_filespecs(Array[input_filespec])
    write_private(input_filespec, json_mode: json_mode, json_filespec: json_filespec)
  end


  # Public entry point to write multiple files.
  # json_mode: :pretty for human readable JSON, :compact for compact JSON
  def write_multiple(input_filespecs, json_mode: :pretty)
    validate_input_filespecs(input_filespecs)
    input_filespecs.each do |input_filespec|
      write_private(input_filespec, json_mode: json_mode)
    end
  end


  # Implementation for writing a single file.
  # Separated from the public `write` method in order to validate filespecs only once.
  # Default json_filespec will be constructed from the input file, just replacing 'xml' with 'json'.
  private
  def write_private(input_filespec, json_mode: :pretty, json_filespec: nil)
    json_text = (json_mode == :pretty) ? JSON.pretty_generate(records) : records.to_json
    json_filespec ||= input_filespec.sub(/\.xml$/, '.json')
    File.write(json_filespec, json_text)
    puts "#{records.size} records processed, #{input_filespec} --> #{json_filespec}"
  end
end
end
