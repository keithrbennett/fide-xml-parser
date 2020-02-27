# FIDE Chess Player Rating Information XML to JSON Converter & Data Analyzer

This repo contains two scripts:
 
* [fide_xml_to_json.rb](fide_xml_to_json.rb) - generates a JSON file from an XML file downloaded from [https://ratings.fide.com/download_lists.phtml](https://ratings.fide.com/download_lists.phtml) or [https://ratings.fide.com/download.phtml](https://ratings.fide.com/download.phtml).
* [analyze_fide_data.rb](analyze_fide_data.rb) - generates a JSON file containing statistics from a JSON file produced by fide_xml_to_json.rb. This file may not necessarily include information useful to you, but is an example of how the data can be manipulated. Sample output files are in the [samples](./samples) directory.


## Installation Instructions

Download or clone this repository.

These scripts are Ruby scripts. They uses Ruby gems (libraries). Install the gems by running `bundle` in the project directory. (Ruby and these gems work best in Mac OS or Linux. Windows should work but may present challenges.)

If you are running on Mac OS or Linux, you can `chmod +x *.rb` so that you can invoke the scripts without preceding their filespecs with `ruby`.


## Operating Instructions

The scripts output the JSON in "pretty" format that is more human-readable than compact JSON. If you need to, you can use compact mode instead by changing the calls from `JSON.pretty_generate(records)` to `records.to_json`.

### fide_xml_to_json.rb

[fide_xml_to_json.rb](fide_xml_to_json.rb) syntax is:

`ruby fide_xml_to_json.rb my_file.xml`

It will show its progress, and when it is finished parsing all the XML records will write the JSON representation of the parsed data to a file whose name is the same as the XML file, but with `.xml` changed to `.json`.

### analyze_fide_data.rb

[analyze_fide_data.rb](./analyze_fide_data.rb) syntax is:

`ruby analyze_fide_data.rb my_file.json`

It will read and parse the JSON file, analyze the data, and then output it (in pretty JSON format) to a file whose name is the same as the input file's, but with a `-stats` inserted before the `.json`.


## Adding Your Own Functionality

Assuming one can write even simple Ruby code, manipulating the data is easy.
 
You can write a script that includes:

```ruby
require 'json'
records = JSON.parse(File.read('my_file.json'))
```

...and then use Ruby's excellent [Enumerable support](https://ruby-doc.org/core-2.7.0/Enumerable.html) to analyze or manipulate the `records` array.
 
As examples, the following can easily be done:

* _field filtering_ - exclude some fields from the JSON output
* _record filtering_ - exclude records meeting specified criteria
* _statistical analysis_ - analysis of the parsed data
* _data validation_ - to look for data errors and ambiguities

You could also insert the following to get an interactive Ruby shell where `self` is the records array. (You may need to `gem install pry` if it hasn't already been installed.):

```ruby
require 'pry'
records.pry
```
