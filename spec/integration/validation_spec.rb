require "spec_helper"

module HTML5
  module Tdd
    describe Validator do
      let(:object)        { described_class }
      let(:html_document) { Example1::INVALID_HTML }
      let(:arguments)     { [html_document] }

      context ".validate" do

        subject { object.validate(*arguments) }

        it "indicates if errors are present" do
          subject.errors?.should be_true
        end

        describe "no errors" do
          let(:html_document) { Example1::VALID_HTML }

          it "has no errors" do
            subject.errors?.should be_false
          end
        end

        describe :errors do

          subject { object.validate(*arguments).errors }

          it "has errors" do
            subject.size.should eq(2)
          end

          it "has errors messages" do
            subject.first.message.should eq("Element img is missing required attribute src.")
            subject.last.message.should eq("An img element must have an alt attribute, except under certain conditions. For details, consult guidance on providing text alternatives for images.")
          end

          describe :location do
            it "has errors locations" do
              subject.first.location.should == Validator::Location.new(9, 1, 9, 5)
              subject.first.location.ll.should eq(9)
              subject.first.location.lc.should eq(1)

              subject.first.location.rl.should eq(9)
              subject.first.location.rc.should eq(5)
            end
          end
        end
      end
    end
  end
end
