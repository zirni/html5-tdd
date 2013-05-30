require "spec_helper"

require "open3"

describe "Executable" do

  context "without arguments" do

    it "displays usage information" do

      Open3.popen3("bin/html5-tdd") do |i, o, e, t|
        stderr = e.read.chomp
        stderr.should eq("")

        stdout = o.read.chomp
        stdout.should include("Usage:\n\thtml5-tdd <uri>")

        exitstatus = t.value
        exitstatus.should eq(0)

      end

    end

  end

  context "wit arguments" do

    it "accepts http uri" do
      uri = "https://raw.github.com/zirni/html5-tdd/master/spec/fixtures/example1/invalid.html"

      Open3.popen3("bin/html5-tdd #{uri}") do |i, o, e, t|

        stderr = e.read.chomp
        stderr.should eq("")

        stdout = o.read.chomp
        stdout.should include("1. Element img is missing required attribute src.
\tFrom line 9, column 1; to line 9, column 5

2. An img element must have an alt attribute, except under certain conditions. For details, consult guidance on providing text alternatives for images.
\tFrom line 9, column 1; to line 9, column 5")

        stdout.should match(/Finished in \d+\.\d\d? seconds\n2 Errors/)

        exitstatus = t.value.exitstatus
        exitstatus.should eq(1)

      end
    end

    it "accepts http uri" do
      uri = "https://raw.github.com/zirni/html5-tdd/master/spec/fixtures/example1/valid.html"

      Open3.popen3("bin/html5-tdd #{uri}") do |i, o, e, t|
        stderr = e.read.chomp
        stderr.should eq("")

        stdout = o.read.chomp
        stdout.should match(/HTML is valid.\n\nFinished in \d+\.\d\d? seconds/)

        exitstatus = t.value
        exitstatus.should eq(0)
      end
    end
  end
end
