lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fide_xml_parser/version"

Gem::Specification.new do |spec|
  spec.name          = "fide_xml_parser"
  spec.version       = FideXmlParser::VERSION
  spec.authors       = ["Keith Bennett"]
  spec.email         = ["keithrbennett@gmail.com"]

  spec.summary       = %q{Parses XML files downloaded from fide.com and writes JSON files.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/keithrbennett/fide-xml-parser"
  spec.license       = "Apache-2.0"

  spec.metadata['allowed_push_host'] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = '' # "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(bin|test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~>1.10"
  spec.add_dependency "tty-cursor", "~> 0.7"
  spec.add_dependency "pry", "~> 0.12"
  spec.add_dependency "awesome_print", "~> 1.8"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
