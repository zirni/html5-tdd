module HTML5
  module Tdd
    class Validator
      class Location
        include Equalizer.new(:ll, :lc, :rl, :rc)

        attr_reader :ll, :lc, :rl, :rc

        def initialize(ll, lc, rl, rc)
          @ll = ll
          @lc = lc
          @rl = rl
          @rc = rc
        end
      end
    end
  end
end
