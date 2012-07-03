require 'spec_helper'

describe ConsoleWindow::Window do

  let(:window) { described_class.new(width: 80, height: 20) }
  subject { window }

  describe "#lines" do
    subject { window.lines }
    it { should be_empty }
    its([0]) { should == [] }

    shared_examples_for "a setter" do

      its([0]) { should == %w[h e l l o] }
      example { subject.join("\n").should == "hello" }
    end

    context "#[]=" do
      it_behaves_like "a setter"

      before do
        subject[0] = "hello"
      end
    end

    context "#<<" do
      it_behaves_like "a setter"

      before do
        subject << "hello"
      end
    end

    describe "#join" do
      example do
        subject << 'abc'
        subject << 'def'
        subject.join(';').should == %w[abc def].join(';')
      end
    end
  end
end
