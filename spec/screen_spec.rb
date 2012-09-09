# -*- coding: utf-8 -*-
require 'spec_helper'

describe ConsoleWindow::Screen do

  let(:curses_mock) { CursesMock.new }
  let(:stdscr_mock) { CursesWindowMock.new }

  subject { described_class.new(curses: curses_mock) }

  before do
    curses_mock.stub!(:stdscr) { stdscr_mock }
  end

  describe "#new" do

    it "should not start curses screen now." do
      curses_mock.should_not_receive(:init_screen)
      curses_mock.should_not_receive(:close_screen)
      described_class.new
    end
  end

  describe "#activate" do

    after { subject.activate }

    it "should init screen." do
      curses_mock.should_receive(:init_screen)
    end

    it "should close screen." do
      curses_mock.should_receive(:close_screen)
    end

    it "should use non-blocking read." do
      curses_mock.should_receive(:timeout=).with(0)
    end

    it "should use noecho mode." do
      curses_mock.should_receive(:noecho)
    end

    it "should use keypad." do
      stdscr_mock.should_receive(:keypad).with(true)
    end
  end

  describe "#getc" do

    let(:curses_window_mock) { CursesWindowMock.new(input_text: "あいう") }
    let(:input) { ConsoleWindow::CursesIO.new(curses_window_mock) }
    let(:screen) { ConsoleWindow::Screen.new(curses: curses_mock, curses_io: input) }
    subject { screen } 

    example do
      subject.getc.should == "あ"
      subject.getc.should == "い"
      subject.getc.should == "う"
      #subject.getc.should be_nil
    end
  end

  context "Frame-looping" do
    let(:curses_window_mock) { CursesWindowMock.new(input_text: "あいう\n") }
    let(:screen) { ConsoleWindow::Screen.new(curses: curses_mock) }
    let(:window) { ConsoleWindow::Window.new(owner: screen, width: 80, height: 20) }

    before do
      curses_mock.stub!(:stdscr) { curses_window_mock }
    end

    subject { screen } 

    before do
      window.frames.on :main do
        @char = window.getc
        window.unfocus!
      end

      window.focus!
      subject.components << window
    end

    example do
      subject.activate
      @char.should == "あ"
    end
    
    example "Frames#before" do
      count = 0

      window.frames.before :main do
        count += 1
      end

     subject.activate

      count.should == 1
    end
    
    example "Frames#after" do
      count = 0

      window.frames.after :main do
        count += 1
      end

      subject.activate

      count.should == 1
    end
  end
end
