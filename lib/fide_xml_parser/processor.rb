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
class Processor < Nokogiri::XML::SAX::Document

  attr_reader :start_time
  attr_accessor :current_property_name, :record, :records, :key_filter, :record_filter,
                :input_record_count, :output_record_count

  ANSI_GO_TO_LINE_START = "\033[1G"

  NUMERIC_FIELDS = %w[
    k
    blitz_k
    rapid_k
    rating
    blitz_rating
    rapid_rating
    games
    blitz_games
    rapid_games
  ]

  def initialize
    @key_filter = nil
    @record_filter = nil
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
    when 'playerslist'
      # ignore
    when 'player'
      self.input_record_count += 1
      output_status if input_record_count % 1000 == 0
    else # this is a field in the players record; process it as such
      self.current_property_name = name
    end
  end


  def end_element(name)
    case name
    when 'playerslist'  # end of data, write JSON file
      finish
    when 'player'
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
        value = NUMERIC_FIELDS.include?(current_property_name) ? Integer(string) : string
        record[current_property_name] = value
      end
    end
  end


  def finish
    output_status
    puts
  end
end
end
