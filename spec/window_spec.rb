require 'spec_helper'

describe ConsoleWindow::Window do

  let(:window) { described_class.new(width: 80, height: 20) }
  subject { window }

  describe "the default value of each attritbes." do

    its(:lines) { should == [] }
    its(:as_text) { should == "" }
    its(:as_displayed_text) { should == "" }
    its(:as_full_text) { should == "" }

    its(:x) { should == 0 }
    its(:y) { should == 0 }
    its('location.x') { should == 0 }
    its('location.y') { should == 0 }
    its('location.absolute_x') { should == 0 }
    its('location.absolute_y') { should == 0 }

    its(:width) { should == 80 }
    its(:height) { should == 20 }
    its('size.width') { should == 80 }
    its('size.height') { should == 20 }

    its('position.x') { should == 0 }
    its('position.y') { should == 0 }
    its('position.absolute_x') { should == 0 }
    its('position.absolute_y') { should == 0 }

    its('cursor.x') { should == 0 }
    its('cursor.y') { should == 0 }
    its('cursor.absolute_x') { should == 0 }
    its('cursor.absolute_y') { should == 0 }

    its('scroll.x') { should == 0 }
    its('scroll.y') { should == 0 }
    its('scroll.absolute_x') { should == 0 }
    its('scroll.absolute_y') { should == 0 }


    example do
      subject.x = 5
      subject.location.x.should == 5
    end

    example do
      subject.location.x = 5
      subject.x.should == 5
    end

    example do
      subject.y = 5
      subject.location.y.should == 5
    end

    example do
      subject.location.y = 5
      subject.y.should == 5
    end

    example do
      subject.width = 40
      subject.size.width.should == 40
    end

    example do
      subject.size.width = 40
      subject.width.should == 40
    end

    example do
      subject.height = 10
      subject.size.height.should == 10
    end

    example do
      subject.size.height = 10
      subject.size.height.should == 10
    end
  end

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

  context do

    before do
      subject.lines << "first line"
      subject.lines << "second line"
      subject.lines << "third line"
      # will be displayed:
      #                 ###########
      #                 ###ond l###
      #                 ###rd li###
      #                 ###~~~~~###
      subject.scroll.x = 3
      subject.scroll.y = 1
      subject.width = 5
      subject.height = 2
    end

    its(:as_displayed_text) { should == ["ond l", "rd li"].join("\n") }
  end

  describe "replace char" do
    before do
      subject.lines << '*-*'
      subject.lines << '|a|'
      subject.lines << '*-*'
      subject.lines[1][1] = 'b'
    end

    its(:as_text) { should == %w[*-* |b| *-*].join("\n") }
  end

  describe "#print_rect" do

    before do
      subject.lines << "###"
      subject.lines << "###"
      subject.lines << "###"
    end
    
    context do
      before do
        subject.position.x = 0
        subject.position.y = 0
        subject.print_rect "@@\n" +
                           "@@"
      end

      its(:as_text) { should == %w[@@# @@# ###].join("\n") }
      its(:lines) { should == %w[@@# @@# ###] }
    end
    
    context do
      before do
        subject.position.x = 1
        subject.position.y = 0
        subject.print_rect "@@\n" +
                           "@@"
      end

      its(:as_text) { should == %w[#@@ #@@ ###].join("\n") }
      its(:lines) { should == %w[#@@ #@@ ###] }
    end
    
    context do
      before do
        subject.position.x = 0
        subject.position.y = 1
        subject.print_rect "@@\n" +
                           "@@"
      end

      its(:as_text) { should == %w[### @@# @@#].join("\n") }
      its(:lines) { should == %w[### @@# @@#] }
    end
    context do
      before do
        subject.position.x = 3
        subject.position.y = 3
        subject.print_rect "@@\n" +
                           "@@"
      end

      its(:as_text) { should == [ "###",
                                  "###",
                                  "###",
                                  "   @@",
                                  "   @@" ].join("\n") }
    end
  end
end
