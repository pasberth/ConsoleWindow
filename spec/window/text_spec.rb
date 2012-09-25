# -*- coding: utf-8 -*-
require 'spec_helper'

describe ConsoleWindow::Window::Text do

  subject { described_class.new(window) }
  let(:window) { ConsoleWindow::Window.new(owner: nil, width: 80, height: 20) }

  describe "#[]" do

    its([0]) { should be_nil }
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

    it "will insert a new line at window.position" do
      subject << "hello"
      window.position.x = 2
      window.position.y = 0
      subject << "world"
      subject.as_string.should == <<-A
heworld
llo
A
    end
  end

  
  describe "#as_displayed_string" do

    context "Resizing" do

      before do
        window.width = 2
        window.height = 2

        subject[0] = "###"
        subject[1] = "###"
        subject[2] = "###"
      end

      its(:as_string) { should == <<-A }
###
###
###
A

      its(:as_displayed_string) { should == <<-A }
##
##
A

      example do
        window.width = 1
        window.height = 1
        subject.as_displayed_string.should == "#\n"
      end

      example do
        window.width = 3
        window.height = 3
        subject.as_displayed_string.should == <<-A
###
###
###
A
      end

      example do
        window.width = 3
        window.height = 1
        subject.as_displayed_string.should == <<-A
###
A
      end

      example do
        window.width = 1
        window.height = 3
        subject.as_displayed_string.should == <<-A
#
#
#
A
      end

      example do
        window.width = 5
        window.height = 5
        subject.as_displayed_string.should == <<-A
###
###
###
A
      end
    end

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
