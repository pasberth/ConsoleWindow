require 'spec_helper'

describe ConsoleWindow::Window::Frames do

  subject { frames }
  let(:frames) { described_class.new(window) }
  let(:window) { ConsoleWindow::Window.new(owner: nil, width: 80, height: 20) }

  shared_examples_for "a frame group" do
    subject { frame_group }

    describe "#on" do
      
      context "put a frame onto the Frames." do
        before do
          subject.on(:main) {}
        end

        it "have the frame 'main'." do
          subject.frame(:main).should be
        end

        context "when the frame 'main' was put two times" do
          
          it "raises error" do
            expect { subject.on(:main) {} }.should raise_error ArgumentError
          end
        end
      end
    end


    describe "#group" do

      it "yield with a group object" do |; group|
        subject.group(:main) { |g| group = g }
        group.should be_kind_of described_class
      end

      it "returns a group object" do
        subject.group(:main).should be_kind_of described_class
      end
    end
  end

  it_behaves_like "a frame group" do
    let(:frame_group) { frames }
  end

  it_behaves_like "a frame group" do
    let(:frame_group) { frames.group(:a_group) }
  end
end
