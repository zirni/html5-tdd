require "open-uri"
require "colorize"

require "html5/tdd"

module HTML5
  module Tdd
    class Cli
      def self.run(argv)
        t = Time.now

        body = open(argv.first).read
        res = Validator.validate(body)

        puts ""

        if res.errors?

          res.errors.each_with_index do |error, i|
            puts "#{i + 1}. #{error.message}".red
            puts "\tFrom line #{error.location.ll}, column #{error.location.lc}; to line #{error.location.rl}, column #{error.location.rc}".cyan
            puts "\t#{error.excerpt}"
            puts ""
          end

          t_diff = (Time.now - t)
          t_diff = (t_diff * 100).to_i / 100.0

          puts "Finished in #{t_diff} seconds"
          puts "#{res.errors.count} Errors"
          puts ""

          exit 1
        else
          puts "HTML is valid.".green
          puts ""

          t_diff = (Time.now - t)
          t_diff = (t_diff * 100).to_i / 100.0

          puts "Finished in #{t_diff} seconds"
          puts ""
        end
      end
    end
  end
end
