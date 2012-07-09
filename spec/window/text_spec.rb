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
      subject[0].as_string.should == "hello world\n"
    end

    example do
      subject[0] = "hello\nworld"
      subject[0].as_string.should == "hello\n"
      subject[1].as_string.should == "world\n"
    end
  end

  describe "#<<" do

    example { subject << "hello"; subject.as_string.should == <<-A }
hello
A
    example { subject << "hello" << "world"; subject.as_string.should == <<-A }
hello
world
A

    it "will insert at window.position.y" do
      window.position.y = 1
      subject << "hello"
      subject.as_string.should == <<-A

hello
A
    end
  end

  describe "#crop" do

    before do
      subject[0] = "__@@"
      subject[1] = "..**"
      subject[2] = ",,++"
    end

    describe "return value" do
      example { subject.crop(0, 0, 5, 1).should be_kind_of ConsoleWindow::Window::Text }
    end

    example { subject.crop(0, 0, 3, 1).as_string.should == "__@\n" }
    example { subject.crop(0, 1, 3, 2).as_string.should == "..*\n" }
    example { subject.crop(1, 0, 4, 1).as_string.should == "_@@\n" }
    example { subject.crop(1, 1, 4, 2).as_string.should == ".**\n" }

    example { subject.crop(2, 0, 20, 1).as_string.should == "@@\n" }
    example { subject.crop(0, 2, 3, 20).as_string.should == ",,+\n" }

    example { subject.crop(10, 10, 20, 20).as_string.should == "" }

    example { subject.crop(0, 0, 3, 3).as_string.should == <<-A }
__@
..*
,,+
A

    example { subject.crop(1, 1, 3, 3).as_string.should == <<-A }
.*
,+
A
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
        subject.as_string.should == "###\n###\n###\n"
      end
    end

    shared_examples_for "an object as a text" do

      example { subject.paste(horizontal_dot_line, 0, 0).as_string.should == <<-A }
...
###
###
A
      example { subject.paste(horizontal_dot_line, 0, 1).as_string.should == <<-A }
###
...
###
A
      example { subject.paste(vertical_dot_line, 0, 0).as_string.should == <<-A }
.##
.##
.##
A
      example { subject.paste(vertical_dot_line, 1, 0).as_string.should == <<-A }
#.#
#.#
#.#
A
      example { subject.paste(dot_box, 0, 0).as_string.should == <<-A }
..#
..#
###
A
      example { subject.paste(dot_box, 1, 0).as_string.should == <<-A }
#..
#..
###
A
      example { subject.paste(dot_box, 0, 1).as_string.should == <<-A }
###
..#
..#
A
      example { subject.paste(dot_box, 1, 1).as_string.should == <<-A }
###
#..
#..
A
      example { subject.paste(dot_box, 2, 2).as_string.should == <<-A }
###
###
##..
  ..
A

      example { subject.paste(dot_box, 4, 4).as_string.should == <<-A }
###
###
###

    ..
    ..
A
    end

    it_behaves_like "an object as a text" do
      let(:horizontal_dot_line) { "..." }
      let(:vertical_dot_line) { ".\n.\n." }
      let(:dot_box) { "..\n.." }
    end

    it_behaves_like "an object as a text" do
      let(:horizontal_dot_line) { described_class.new(window, "...") }
      let(:vertical_dot_line) { described_class.new(window, ".\n.\n.") }
      let(:dot_box) { described_class.new(window, "..\n..") }
    end
  end

  
  describe "#as_displayed_string" do

    context "Scrolling" do

      before do
        subject[0] = "__@@"
        subject[1] = "..**"
        subject[2] = ",,++"
      end

      example do
        window.scroll = [0, 0]
        subject.as_displayed_string.should == <<-A
__@@
..**
,,++
A
      end

      example do
        window.scroll = [1, 0]
        subject.as_displayed_string.should == <<-A
_@@
.**
,++
A
      end

      example do
        window.scroll = [0, 1]
        subject.as_displayed_string.should == <<-A
..**
,,++
A
      end

      example do
        window.scroll = [1, 1]
        subject.as_displayed_string.should == <<-A
.**
,++
A
      end

      example do
        window.scroll = [2, 2]
        subject.as_displayed_string.should == <<-A
++
A
      end
    end
  end
end
