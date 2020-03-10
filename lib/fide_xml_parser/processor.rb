require 'awesome_print'
require 'nokogiri'

module FideXmlParser

# Recommended entry point is Processor.parse, which creates an instance of the class, initiates the parse,
# and returns the parsed data.
#
# Supports key and record filters.

# For key filter, pass a lambda that takes a key name as a parameter
# and returns true to include it, false to exclude it,
# e.g. to exclude 'foo' and 'bar', do this:
# processor.key_filter = ->(key) { ! %w(foo bar).include?(key) }

# For record filter, pass a lambda that takes a record as a parameter,
# and returns true to include it or false to exclude it,
# e.g. to include only records with a "title", do this:
# processor.record_filter = ->(rec) { rec.title }
# If a field name has been changed via the field_name_renames hash, the new name should be used in the filter.

# A field_name_renames hash can be provided.
# Keys are the field names in the XML input, values are the names in the output JSON, e.g.:
#   {
#       'rating' => 'standard_rating',
#       'games'  => 'standard_games'
#   }


class Processor < Nokogiri::XML::SAX::Document

  attr_reader :start_time

  # Constructor parameters:
  attr_accessor :numeric_fields, :array_name, :record_name

  # User-provided callbacks:
  attr_accessor :key_filter, :record_filter, :field_name_renames

  # For internal use:
  attr_accessor :current_property_name, :record, :records, :input_record_count, :output_record_count

  ANSI_GO_TO_LINE_START = "\033[1G"

  def initialize(array_name, record_name, numeric_fields)
    @array_name = array_name
    @record_name = record_name
    @numeric_fields = numeric_fields
    @key_filter = nil
    @record_filter = nil
    @field_name_renames = nil
    @current_property_name = nil
    @record = {}
    @records = []
    @start_time = current_time
    @keys_to_exclude = []
    @input_record_count = 0
    @output_record_count = 0
  end


  def parse(data_source)
    parser = Nokogiri::XML::SAX::Parser.new(self)
    parser.parse(data_source)
    records
  end


  def current_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end


  def output_status
    print ANSI_GO_TO_LINE_START
    print "Records processed: %9d   kept: %9d    Seconds elapsed: %11.2f" % [
        input_record_count,
        output_record_count,
        current_time - start_time
    ]
  end


  def start_element(name, _attrs)
    case name
    when array_name
      # ignore
    when record_name
      self.input_record_count += 1
      output_status if input_record_count % 1000 == 0
    else # this is a field in the players record; process it as such
      self.current_property_name = name
    end
  end


  def end_element(name)
    case name
    when array_name  # end of data, write JSON file
      finish
    when record_name
      if record_filter.nil? || record_filter.(record)
        self.output_record_count += 1
        records << record
      end
      self.record = {}
    else
      self.current_property_name = nil
    end
  end


  def characters(string)
    if current_property_name
      if key_filter.nil? || key_filter.(current_property_name)
        value = numeric_fields.include?(current_property_name) ? Integer(string) : string
        key = current_property_name
        if field_name_renames
          new_field_name = field_name_renames[key]
          if new_field_name
            key = new_field_name
          end
        end
        record[key] = value
      end
    end
  end


  def finish
    output_status
    puts
  end
end
end
