require_relative 'processor'

module FideXmlParser

  class FideProcessor < Processor

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
    ].map(&:freeze)

    def initialize
      super('playerslist', 'player', NUMERIC_FIELDS)
    end
  end
end
