# -*- coding: utf-8 -*-
require 'spec_helper'

describe ConsoleWindow::CursesIO do

  describe "#getc" do

    shared_examples_for "taking a character" do
      let(:curses_window_mock) { CursesWindowMock.new(text: text_source) }
      subject { described_class.new(curses_window_mock) }

      example do
        expecting_chars.each do |char|
          subject.getc.should == char
        end
      end
    end

    it_behaves_like "taking a character" do
      let(:text_source) { "abc" }
      let(:expecting_chars) { ['a', 'b', 'c', nil] }
    end

    it_behaves_like "taking a character" do
      let(:text_source) { "あいう" }
      let(:expecting_chars) { ['あ', 'い', 'う', nil] }
    end
  end

  describe "#gets" do

    shared_examples_for "getting a line" do 
      let(:curses_window_mock) { CursesWindowMock.new(text: text_source) }
      subject { described_class.new(curses_window_mock) }

      example do
        expecting_lines.each do |line|
          subject.gets.should == line
        end
      end
    end

    it_behaves_like "getting a line" do
      let(:text_source) { "abc\ndef\n" }
      let(:expecting_lines) { ["abc\n", "def\n", nil] }
    end

    it_behaves_like "getting a line" do
      let(:text_source) { "abc\ndef" }
      let(:expecting_lines) { ["abc\n", "def", nil] }
    end
  end
end
