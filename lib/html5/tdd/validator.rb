# encoding: utf-8

module HTML5
  module Tdd
    class Validator
      def self.validate(str)
        new(str).validate
      end

      def initialize(str)
        @str = str
      end

      def validate
        result = Engine.get(@str)

        doc = Nokogiri::HTML(result)
        errors = doc.css("ol > li.error")

        e = errors.map do |error|
          message = error.css("p:first span").text
          locations = error.css("p.location span").map(&:text).map(&:to_i)
          excerpt = error.css("p.extract code").text

          Error.new(message, Location.new(*locations), excerpt)
        end

        Result.new(e)
      end
    end
  end
end
