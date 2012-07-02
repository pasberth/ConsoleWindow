require 'spec_helper'

describe ConsoleWindow::Window do

  let(:owner) { ConsoleWindow::Container.new(width: 80, height: 20) }

  let(:x) { 20 }
  let(:y) { 10 }
  let(:width) { 60 }
  let(:height) { 10 }
  subject { described_class.new(owner: owner, width: width, height: height, x: x, y: y) }

  its(:owner) { should == owner }
  its(:x) { should == x }
  its(:y) { should == y }
  its(:width) { should == width }
  its(:height) { should == height }
  its('location.x') { should == x }
  its('location.y') { should == y }
  its('location.absolute_x') { should == x }
  its('location.absolute_y') { should == y }

  its('position.x') { should == 0 }
  its('position.y') { should == 0 }
  its('position.absolute_x') { should == x }
  its('position.absolute_y') { should == y }

  its('cursor.x') { should == 0 }
  its('cursor.y') { should == 0 }
  its('cursor.absolute_x') { should == x }
  its('cursor.absolute_y') { should == y }

  its('scroll.x') { should == 0 }
  its('scroll.y') { should == 0 }
  its('scroll.absolute_x') { should == x }
  its('scroll.absolute_y') { should == y }
end
