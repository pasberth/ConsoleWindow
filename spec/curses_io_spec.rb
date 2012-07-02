# -*- coding: utf-8 -*-
require 'spec_helper'

describe ConsoleWindow::CursesIO do

  context do
    let(:curses_window_mock) { CursesWindowMock.new(text: "abc") }
    subject { described_class.new(curses_window_mock) }

    example do
      subject.getc.should == 'a'
      subject.getc.should == 'b'
      subject.getc.should == 'c'
      subject.getc.should be_nil
    end
  end

  context do
    let(:curses_window_mock) { CursesWindowMock.new(text: "あいう") }
    subject { described_class.new(curses_window_mock) }

    example do
      subject.getc.should == 'あ'
      subject.getc.should == 'い'
      subject.getc.should == 'う'
      subject.getc.should be_nil
    end
  end

  context do
    let(:curses_window_mock) { CursesWindowMock.new(text: "abc\ndef\n") }
    subject { described_class.new(curses_window_mock) }

    example do
      subject.gets.should == "abc\n"
      subject.gets.should == "def\n"
      subject.gets.should be_nil
    end
  end
end
