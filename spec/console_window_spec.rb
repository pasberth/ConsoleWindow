require 'console_window'
describe ConsoleWindow::Window do

  its(:lines) { should == [] }
  its(:as_text) { should == "" }
  its(:as_displayed_text) { should == "" }
  its(:as_full_text) { should == "" }

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
end
