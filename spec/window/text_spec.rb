require 'spec_helper'

describe ConsoleWindow::Window::Text do

  subject { described_class.new(window) }

  let(:window) { ConsoleWindow::Window.new(owner: nil, width: 80, height: 20) }

  describe "#[]" do

    its([0]) { should be_kind_of ConsoleWindow::Window::Text::Line }
    its([0]) { should be_empty }
  end

  describe "#[]=" do

    example do
      subject[0] = "hello world"
      subject[0].to_s.should == "hello world\n"
    end

    example do
      subject[0] = "hello\nworld"
      subject[0].to_s.should == "hello\n"
      subject[1].to_s.should == "world\n"
    end
  end

  describe "#<<" do

    example { subject << "hello"; subject.to_s.should == <<-A }
hello
A
    example { subject << "hello" << "world"; subject.to_s.should == <<-A }
hello
world
A

    it "will insert at window.position.y" do
      window.position.y = 1
      subject << "hello"
      subject.to_s.should == <<-A

hello
A
    end
  end

  describe "#crop" do

    before do
      subject[0] = "first line"
      subject[1] = "second line"
    end

    describe "return value" do
      example { subject.crop(0, 0, 5, 1).should be_kind_of ConsoleWindow::Window::Text }
    end

    example { subject.crop(0, 0, 5, 1).to_s.should == "first\n" }
    example { subject.crop(0, 0, 5, 2).to_s.should == "first\nsecon\n" }
    example { subject.crop(5, 0, 10, 1).to_s.should == " line\n" }
    example { subject.crop(5, 1, 10, 2).to_s.should == "d lin\n" }
  end

  describe "#paste" do

    before do
      subject[0] = "###"
      subject[1] = "###"
      subject[2] = "###"
    end

    describe "return value" do

      example { subject.paste("@@@", 0, 0).should be_kind_of ConsoleWindow::Window::Text }
    end

    describe "site effect" do

      example do
        subject.paste("@@@", 0, 0)
        subject.to_s.should == "###\n###\n###\n"
      end
    end

    example { subject.paste("@@@", 0, 0).to_s.should == <<-A }
@@@
###
###
A
    example { subject.paste("@@@", 0, 1).to_s.should == <<-A }
###
@@@
###
A
    example { subject.paste(".\n.\n.", 0, 0).to_s.should == <<-A }
.##
.##
.##
A
    example { subject.paste(".\n.\n.", 1, 0).to_s.should == <<-A }
#.#
#.#
#.#
A
  end
end
