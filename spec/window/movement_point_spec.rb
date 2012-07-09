require 'spec_helper'

describe ConsoleWindow::Window do

  shared_examples_for "the movement point" do

    its(:max_x) { should_not be_nil }
    its(:max_y) { should_not be_nil }
    its(:min_x) { should_not be_nil }
    its(:min_y) { should_not be_nil }

    describe "#up!" do

      context "can up" do

        before do
          subject.y = subject.min_y + 2
        end

        example do
          subject.up!.should be_true
        end
        
        example do
          subject.up!
          subject.y.should == subject.min_y + 1
        end
      end
      
      context "can't up" do

        before do
          subject.y = subject.min_y
        end
        
        example do
          subject.up!.should be_false
        end

        example do
          subject.up!
          subject.y.should == subject.min_y
        end
      end
    end

    describe "#left!" do

      context "can left" do

        before do
          subject.x = subject.max_x
        end

        example do
          subject.left!.should be_true
        end
  
        example do
          subject.left!
          subject.x.should == subject.max_x - 1
        end
      end

      context "can't left" do
        
        before do
          subject.x = subject.min_x
        end

        example do
          subject.left!.should be_false
        end

        example do
          subject.left!
          subject.x.should == subject.min_x
        end
      end
    end
    
    describe "#right!" do
      
      context "can right" do
        
        before do
          subject.x = subject.min_x
        end

        example do
          subject.right!.should be_true
        end
        
        example do
          subject.right!
          subject.x.should == subject.min_x + 1
        end
      end
      
      context "can't right" do
        
        before do
          subject.x = subject.max_x
        end
        
        example do
          subject.right!.should be_false
        end
        
        example do
          subject.right!
          subject.x.should == subject.max_x
        end
      end
    end
    
    describe "#down!" do
      
      context "can down" do
        
        before do
          subject.y = subject.min_y
        end

        example do
          subject.down!.should be_true
        end
        
        example do
          subject.down!
          subject.y.should == subject.min_y + 1
        end
      end
      
      context "can't down" do
        
        before do
          subject.y = subject.max_x
        end
        
        example do
          subject.down!.should be_false
        end

        example do
          subject.down!
          subject.y.should == subject.max_x
        end
      end
    end
  end

  describe ConsoleWindow::Window::Cursor do

    let(:window) { ConsoleWindow::Window.new(width: 20, height: 10) }
    subject { window.cursor }
    it_behaves_like "the movement point"
  end

  describe ConsoleWindow::Window::Scroll do

    let(:window) { ConsoleWindow::Window.new(width: 20, height: 10) }
    subject { window.scroll }
    it_behaves_like "the movement point"
  end
end
