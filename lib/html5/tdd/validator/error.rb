module HTML5
  module Tdd
    class Validator
      class Error
        attr_reader :message, :location

        def initialize(message, location)
          @message = message
          @location = location
        end
      end
    end
  end
end
