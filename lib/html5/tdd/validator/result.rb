module HTML5
  module Tdd
    class Validator
      class Result
        attr_reader :errors

        def initialize(errors)
          @errors = errors
        end

        def errors?
          errors.size > 0
        end
      end
    end
  end
end
