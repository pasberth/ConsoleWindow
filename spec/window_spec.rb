# -*- coding: utf-8 -*-
require 'spec_helper'

describe ConsoleWindow::Window do

  let(:window) { described_class.new(owner: nil, width: 80, height: 20) }

  subject { window }


  describe "the default value of each attritbes." do

    its('text.as_string') { should == '' }
    its(:as_string) { should == "" }
    its(:as_displayed_string) { should == "" }

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
end
