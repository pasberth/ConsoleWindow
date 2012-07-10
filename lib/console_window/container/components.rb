
module ConsoleWindow

  class Container

    class Components < Struct.new :window, :list

      include Enumerable

      def each &block
        list.each &block
      end

      def << comp
        comp.owner = window
        list << comp
        self
      end
    end
  end
end
