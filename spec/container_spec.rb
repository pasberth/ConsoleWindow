require 'spec_helper'

describe ConsoleWindow::Container do

  subject { ConsoleWindow::Container.new(:width => 80, :height => 20) }

  its(:components) { should have(0).items }

  describe "add windows" do

    before do

      @main_window = ConsoleWindow::Window.new(:width => 80, :height => 18)
      18.times do |i|
        @main_window.lines[i] = '#' * 80
      end

      @info_line = ConsoleWindow::Window.new(width: 80, height: 1, y: 18)
      @info_line.lines[0] = '%-80s' % 'Information line'
      @command_line = ConsoleWindow::Window.new(width: 80, height: 1, y: 19)
      @command_line.lines[0] = '%-80s' % 'Command line'
      subject.components << @main_window << @info_line << @command_line
    end

    its(:components) { should have(3).items }
    its(:as_text) { should == <<-A.chomp }
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
Information line                                                                
Command line                                                                    
                              A

    describe "change size" do
      before do
        subject.width = 20
        subject.height = 5
      end

      its(:as_displayed_text) { should == <<-A.chomp }
####################
####################
####################
####################
####################
A
    end

    describe "scroll down" do
      before do
        subject.scroll.y = 15
      end
      
      its(:as_displayed_text) { should == <<-A.chomp }
################################################################################
################################################################################
################################################################################
Information line                                                                
Command line                                                                    
A
    end

    context "replace a line" do
      before do
        @info_line.lines[0] = 'New info'
      end

      its(:as_displayed_text) { should_not include "Information line" }
      its(:as_displayed_text) { should include "New info" }
    end
  end
end
