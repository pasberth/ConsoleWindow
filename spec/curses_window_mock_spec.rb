# -*- coding: utf-8 -*-
require 'spec_helper'

describe ConsoleWindow::CursesWindowMock do

  let(:width) { 10 }
  let(:height) { 5 } 
  subject do
    described_class.new( maxx: width,
                         maxy: height )
  end

  its(:maxx) { should == width }
  its(:maxy) { should == height }
  its(:screen) { should == [] }
  its(:input_text) { should == '' }

  describe "#addstr" do
    shared_examples_for "string additions" do
      before do
        subject.addstr(text)
      end
      its(:screen) { should == expecting_screen }
    end

    it_behaves_like "string additions" do

      let(:text) { "abc" }
      let(:expecting_screen) { [%w[a b c]] }
    end

    it_behaves_like "string additions" do

      let(:text) { "hello world. this is a long string." }
      let(:expecting_screen) { <<-A.chomp.each_char.each_slice(width).to_a }
hello world. this is a long string.
A
    end

    it_behaves_like "string additions" do

      let(:text) { "あいう" }
      let(:expecting_screen) { [%w[あ い う]] }
    end
  end

  describe "#getch" do

    shared_examples_for "Taking a character" do

      before do
        subject.input_text = input_text
      end

      example do
        expecting_chars do |c|
          subject.getch.should == c
        end
      end
    end

    it_behaves_like "Taking a character" do
      let(:input_text) { "abc" }
      let(:expecting_chars) { ['a', 'b', 'c', nil] }
    end

    it_behaves_like "Taking a character" do
      let(:input_text) { "あいう" }
      let(:expecting_chars) { "あいう".each_byte.to_a + [nil] }
    end
  end
end
