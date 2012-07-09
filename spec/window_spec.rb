# -*- coding: utf-8 -*-
require 'spec_helper'

describe ConsoleWindow::Window do

  let(:window) { described_class.new(owner: nil, width: 80, height: 20) }

  subject { window }


  describe "the default value of each attritbes." do

    its('text.as_string') { should == '' }
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

    its('logical_cursor.x') { should == 0 }
    its('logical_cursor.y') { should == 0 }
  end

  describe "#logical_cursor" do

    context do
      let(:cursor_x) { 10 }
      let(:cursor_y) { 5 }
      let(:scroll_x) { 10 }
      let(:scroll_y) { 5 }
      
      before do
        subject.cursor = [cursor_x, cursor_y]
        subject.scroll = [scroll_x, scroll_y]
      end
      
      its('logical_cursor.x') { should == cursor_x + scroll_x }
      its('logical_cursor.y') { should == cursor_y + scroll_y }
    end
  end

  describe "Setting attributes" do

    context do
      let(:x) { 10 }
      let(:y) { 5 }
        
      before { subject.location = [x, y] }
        
      its(:x) { should == x }
      its(:y) { should == y }
      its('location.x') { should == x }
      its('location.y') { should == y }
    end

    context do
      let(:w) { 10 }
      let(:h) { 5 }
        
      before { subject.size = [w, h] }
        
      its(:width) { should == w }
      its(:height) { should == h }
      its('size.width') { should == w }
      its('size.height') { should == h }
    end

    context do
      let(:x) { 10 }
      let(:y) { 5 }
        
      before { subject.position = [x, y] }
        
      its('position.x') { should == x }
      its('position.y') { should == y }
    end

      context do
      let(:x) { 10 }
      let(:y) { 5 }
      
      before { subject.cursor = [x, y] }
      
      its('cursor.x') { should == x }
      its('cursor.y') { should == y }
    end
    
    context do
      let(:x) { 10 }
      let(:y) { 5 }
      
      before { subject.scroll = [x, y] }
      
      its('scroll.x') { should == x }
      its('scroll.y') { should == y }
    end

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
      subject.height.should == 10
    end

    example do
      pending "論理カーソルへの代入は物理カーソルでどこを示せばよいか未定義" do
        subject.logical_cursor = [10, 10]
      end
    end
  end


  describe "To Text Methods" do

    shared_examples_for "general testing" do

      its(:as_text) { should == expecting_full_text }
      its(:as_full_text) { should == expecting_full_text }
      its(:as_displayed_text) { should == expecting_displayed_text }
    end

    it_behaves_like "general testing" do

      let(:expecting_full_text) { <<-A.chomp }
first line
next line
A
      let(:expecting_displayed_text) { expecting_full_text }

      before do
        subject.lines << "first line"
        subject.lines << "next line"
      end
    end

    it_behaves_like "general testing" do

      let(:expecting_full_text) { <<-A.chomp }
$0
%1
&2
A
      let(:expecting_displayed_text) { <<-A.chomp }
1
2
A
      before do
        subject.lines << "$0"
        subject.lines << "%1" # <- scroll.y = 1
        subject.lines << "&2"
        #                  ^ scroll.x = 1
        subject.scroll.x = 1
        subject.scroll.y = 1
      end      
    end

    it_behaves_like "general testing" do
      let(:expecting_full_text) { "hello world. this is a long string." }
      let(:expecting_displayed_text) { "hello" }

      before do
        subject.lines << "hello world. this is a long string."
        #                     ^ width = 5
        subject.width = 5
      end
    end

    it_behaves_like "general testing" do
      let(:expecting_full_text) { <<-A.chomp }
_1
_2
_3
          A
      let(:expecting_displayed_text) { <<-A.chomp }
_1
_2
          A
      before do
        subject.lines << "_1"
        subject.lines << "_2" # <- height = 2
        subject.lines << "_3"
        subject.height = 2
      end
    end

    it_behaves_like "general testing" do
      let(:expecting_full_text) { <<-A.chomp }
first line
second line
third line
A
      let(:expecting_displayed_text) { <<-A.chomp }
ond l
rd li
A
      before do
        subject.lines << "first line"
        subject.lines << "second line"
        subject.lines << "third line"
        subject.scroll.x = 3
        subject.scroll.y = 1
        subject.width = 5
        subject.height = 2
      end
    end

    it_behaves_like "general testing" do
      let(:expecting_full_text) { <<-A.chomp }
*-*
|b|
*-*
A
      let(:expecting_displayed_text) { expecting_full_text }

      before do
        subject.lines << '*-*'
        subject.lines << '|a|'
        subject.lines << '*-*'
        subject.lines[1][1] = 'b'
      end
    end
  end
end
