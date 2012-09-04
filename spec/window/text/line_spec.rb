require 'spec_helper'

describe ConsoleWindow::Window::Text::Line do

  subject { described_class.new }

  shared_examples_for "the null line" do
    it { should be_empty }
  end

  shared_examples_for "a line" do
    it { should_not be_empty }
  end

  context "init with the nil" do

    subject { described_class.new(nil) }

    it_behaves_like "the null line"
  end

  context "init with a empty string" do

    subject { described_class.new('') }

    it_behaves_like "the null line"
  end

  context "init with LF" do

    subject { described_class.new("\n") }
    it_behaves_like "a line"
  end

  describe "#[range]" do

    subject { described_class.new('hello world') }

    example { subject[0..5].as_string.should == "hello\n" }
    example { subject[1..5].as_string.should == "ello\n" }
    example { subject[0..0].as_string.should == "\n" }
  end

  describe "#[range]=" do
    subject { described_class.new('hello world') }
    example { subject[0..5] = 'herro'; subject.as_string.should == "herro world\n" }
    example { subject[0..5] = %w[h e r r o]; subject.as_string.should == "herro world\n" }
    example { subject[0..5] = described_class.new('herro'); subject.as_string.should == "herro world\n" }
  end

  describe "#[integer]" do

    context "ANSI Color" do

      subject { described_class.new("\e[1mhello\e[m\n") }
      its([0]) { should == "\e[1m" }
      its([1]) { should == "h" }
      its([2]) { should == "e" }
      its([3]) { should == "l" }
      its([4]) { should == "l" }
      its([5]) { should == "o" }
      its([6]) { should == "\e[m" }
    end

    context "Multiple ANSI Color" do

      subject { described_class.new("\e[1;32mhello\e[m\n") }
      its([0]) { should == "\e[1;32m" }
      its([1]) { should == "h" }
      its([2]) { should == "e" }
      its([3]) { should == "l" }
      its([4]) { should == "l" }
      its([5]) { should == "o" }
      its([6]) { should == "\e[m" }
    end
  end
end
