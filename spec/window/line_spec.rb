require 'spec_helper'

describe ConsoleWindow::Window::Text::Line do

  subject { described_class.new(window) }
  let(:window) { ConsoleWindow::Window.new(owner: nil, width: 80, height: 20) }

  shared_examples_for "the null line" do
    it { should be_empty }
  end

  shared_examples_for "a line" do
    it { should_not be_empty }
  end

  context "init with the nil" do

    subject { described_class.new(window, nil) }

    it_behaves_like "the null line"
  end

  context "init with a empty string" do

    subject { described_class.new(window, '') }

    it_behaves_like "the null line"
  end

  context "init with LF" do

    subject { described_class.new(window, "\n") }
    it_behaves_like "a line"
  end

  describe "#[range]" do

    subject { described_class.new(window, 'hello world') }

    example { subject[0..5].to_s.should == "hello\n" }
    example { subject[1..5].to_s.should == "ello\n" }
  end

  describe "#[range]=" do
    subject { described_class.new(window, 'hello world') }
    example { subject[0..5] = 'herro'; subject.to_s.should == "herro world\n" }
    example { subject[0..5] = %w[h e r r o]; subject.to_s.should == "herro world\n" }
    example { subject[0..5] = described_class.new(window, 'herro'); subject.to_s.should == "herro world\n" }
  end

  describe "#<<" do
    example { subject << 'h'; subject.to_s.should == "h\n" }
    example { subject << 'h' << 'e' << 'l'; subject.to_s.should == "hel\n" }

    it "will insert at window.position" do
      subject << "hello"
      window.position.x = 0
      subject << 'X'
      subject.to_s.should == "Xhello\n"
    end
  end

  describe "#pop" do
    subject { described_class.new(window, "hello") }
    example { subject.pop.should == 'h' }
    example { subject.pop; subject.to_s.should == "ello\n" }

    context "will remove at window.position" do
      before do
        window.position = [1, 0] # [x, y]
      end

      example { subject.pop.should == 'e' }
      example { subject.pop; subject.to_s.should == "hllo\n" }
    end
  end
end
