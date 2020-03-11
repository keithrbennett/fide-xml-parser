require_relative 'processor'

module FideXmlParser

  class FideProcessor < Processor

    INTEGER_FIELDS = %w[
        k
        blitz_k
        rapid_k
        rating
        blitz_rating
        rapid_rating
        games
        blitz_games
        rapid_games
    ].map(&:freeze)

    def initialize(key_filter: nil, record_filter: nil, field_name_renames: nil)
      super(array_name:         'playerslist',
            record_name:        'player',
            integer_fields:     INTEGER_FIELDS,
            key_filter:         key_filter,
            record_filter:      record_filter,
            field_name_renames: field_name_renames)
    end
  end
end
