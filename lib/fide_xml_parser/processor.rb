require 'awesome_print'
require 'nokogiri'
require 'tty-cursor'

module FideXmlParser

# Recommended entry point is Processor.parse, which creates an instance of the class, initiates the parse,
# and returns the parsed data.
class Processor < Nokogiri::XML::SAX::Document

  attr_reader :start_time
  attr_accessor :current_property_name, :record, :records

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

  def self.parse(data_source)
    document = self.new
    parser = Nokogiri::XML::SAX::Parser.new(document)
    parser.parse(data_source)
    records = document.parsed_data
    records
  end


  def initialize
    @current_property_name = nil
    @record = {}
    @records = []
    @start_time = current_time
  end


  def current_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end


  def output_status(record_count)
    print TTY::Cursor.column(1)
    print "Records processed: %9d   Seconds elapsed: %11.2f" % [
        record_count,
        current_time - start_time
    ]
  end


  def start_element(name, _attrs)
    case name
    when 'playerslist'
      # ignore
    when 'player'
      output_status(records.size) if records.size % 1000 == 0
    else # this is a field in the players record; process it as such
      self.current_property_name = name
    end
  end


  def end_element(name)
    case name
    when 'playerslist'  # end of data, write JSON file
      finish
    when 'player'
      records << record
      self.record = {}
    else
      self.current_property_name = nil
    end
  end


  def characters(string)
    if current_property_name
      value = NUMERIC_FIELDS.include?(current_property_name) ? Integer(string) : string
      record[current_property_name] = value
    end
  end


  def finish
    output_status(records.count)
    puts
  end


  def parsed_data
    records
  end
end
end
