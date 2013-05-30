module HTML5
  module Tdd
    class Validator
      class Error
        attr_reader :message, :location, :excerpt

        def initialize(message, location, excerpt)
          @message = message
          @location = location
          @excerpt = excerpt
        end
      end
    end
  end
end
