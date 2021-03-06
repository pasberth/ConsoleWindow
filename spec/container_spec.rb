require 'spec_helper'

describe ConsoleWindow::Container do

  subject { ConsoleWindow::Container.new(owner: nil, width: 80, height: 20) }

  its(:components) { should have(0).items }

  describe "add a container" do

    before do
      @container = subject.create_sub(ConsoleWindow::Container, 80, 18, 0, 0)
      subject.components << @container
    end
  end

  describe "add windows" do

    before do

      @main_window = subject.create_sub_window(80, 18, 0, 0)
      18.times do |i|
        @main_window.text[i] = '#' * 80
      end
      @info_line = subject.create_sub_window(80, 1, 0, 18)
      @info_line.text[0] = '%-80s' % 'Information line'
      @command_line = subject.create_sub_window(80, 1, 0, 19)
      @command_line.text[0] = '%-80s' % 'Command line'
      subject.components << @main_window << @info_line << @command_line
    end

    its(:components) { should have(3).items }
    its(:as_string) { should == <<-A.chomp }
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

      its(:as_displayed_string) { should == <<-A.chomp }
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
      
      its(:as_displayed_string) { should == <<-A.chomp }
################################################################################
################################################################################
################################################################################
Information line                                                                
Command line                                                                    
A
    end

    context "replace a line" do
      before do
        @info_line.text[0] = 'New info'
      end

      its(:as_displayed_string) { should_not include "Information line" }
      its(:as_displayed_string) { should include "New info" }
    end
  end
end
