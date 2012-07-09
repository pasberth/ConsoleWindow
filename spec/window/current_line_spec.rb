require 'spec_helper'

describe ConsoleWindow::Window::CurrentLine do

  subject { described_class.new(window) }
  let(:window) { ConsoleWindow::Window.new(owner: nil, width: 80, height: 20) }

  its(:window) { should_not be_nil }

  describe "#<<" do
    example { subject << 'h'; subject.as_string.should == "h\n" }
    example { subject << 'h' << 'e' << 'l'; subject.as_string.should == "hel\n" }

    it "will insert at window.position" do
      subject << "hello"
      window.position.x = 0
      subject << 'X'
      subject.as_string.should == "Xhello\n"
    end
  end

  describe "#pop" do
    subject { described_class.new(window) }
    before { subject[0] =  "hello" }
    example { subject.pop.should == 'h' }
    example { subject.pop; subject.as_string.should == "ello\n" }

    context "will remove at window.position" do
      before do
        window.position = [1, 0] # [x, y]
      end

      example { subject.pop.should == 'e' }
      example { subject.pop; subject.as_string.should == "hllo\n" }
    end
  end
end
