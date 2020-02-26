#!/usr/bin/env ruby

# fide_xml_to_json.rb
# converts an XML ratings file to JSON, where the XML file is a combined chess ratings
# XML file downloadable at https://ratings.fide.com/download_lists.phtml.
#
# This will probably work for the other ratings file formats as well, but that is not yet tested.

require 'json'
require 'nokogiri'
require 'tty-cursor'


class MyDocument < Nokogiri::XML::SAX::Document

  attr_reader :json_filespec, :start_time
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

  def initialize(json_filespec)
    @json_filespec = json_filespec
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
    print "\nWriting JSON data file #{json_filespec}..."
    json_text = JSON.pretty_generate(records)
    # json_text = records.to_json  # for compact JSON, use this line instead of the previous one.
    File.write(json_filespec, json_text)

    # Uncomment the line below to get an interactive shell where `self` is the records array.
    # You will need to `gem install pry` so that the interactive shell library is available.
    # require 'pry'; records.pry
    puts 'finished.'
  end
end


class SaxParseRunner

  def validate_xml_filespec(xml_filespec)
    unless xml_filespec \
        && File.file?(xml_filespec) \
        && xml_filespec[-4..-1].downcase == '.xml'
      puts "Error: Syntax is fide_ratings_xml_to_json filename.xml"
      exit(-1)
    end
  end


  def call
    xml_filespec = ARGV[0]
    validate_xml_filespec(xml_filespec)
    json_filespec = xml_filespec[0..-5] + '.json'
    doc = MyDocument.new(json_filespec)
    parser = Nokogiri::XML::SAX::Parser.new(doc)
    parser.parse(File.new(xml_filespec))
  end
end

SaxParseRunner.new.call

