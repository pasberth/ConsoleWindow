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
end
