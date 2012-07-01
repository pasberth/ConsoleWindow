require 'console_window'

class CursesWindowMock

  MAXX = 80
  MAXY = 20

  def maxx
    MAXX
  end

  def maxy
    MAXY
  end
end

describe ConsoleWindow::Window do

  subject { described_class.new(:curses_window => CursesWindowMock.new) }

  its(:lines) { should == [] }
  its(:as_text) { should == "" }
  its(:as_displayed_text) { should == "" }
  its(:as_full_text) { should == "" }

  it { subject.width.should == subject.max_width }
  it { subject.height.should == subject.max_height }

  context do

    let(:expecting_lines) { ["first line", "next line"] }

    before do
      subject.lines << "first line"
      subject.lines << "next line"
    end

    its(:lines) { should == expecting_lines }
    its(:as_text) { should == expecting_lines.join("\n") }
    its(:as_full_text) { should == expecting_lines.join("\n") }
    its(:as_displayed_text) { should == expecting_lines.join("\n") }
  end

  context do
    before do
      subject.lines << "$0"
      subject.lines << "%1" # <- scroll.y = 1
      subject.lines << "&2"
      #                  ^ scroll.x = 1
      subject.scroll.x = 1
      subject.scroll.y = 1
    end

    its(:lines) { should == %w[$0 %1 &2] }
    its(:as_text) { should == %w[$0 %1 &2].join("\n") }
    its(:as_full_text) { should == %w[$0 %1 &2].join("\n") }
    its(:as_displayed_text) { should == %w[1 2].join("\n") }
  end

  context do

    before do
      subject.lines << "hello world. this is a long string."
      #                     ^ width = 5
      subject.width = 5
    end

    its(:as_displayed_text) { should == "hello" }
  end

  context do
    before do
      subject.lines << "_1"
      subject.lines << "_2" # <- height = 2
      subject.lines << "_3"
      subject.height = 2
    end

    its(:as_displayed_text) { should == %w[_1 _2].join("\n") }
  end
end
