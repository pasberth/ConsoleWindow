require 'console_window/window/text'

module ConsoleWindow

  class Window

    class CurrentLine

      attr_accessor :window

      def initialize window
        @window = window
      end
      
      def method_missing f, *args, &block
        if [:insert, :delete].include? f
          window.text[window.position.y].send f, @window.position.x, *args, &block
        elsif window.text[window.position.y].respond_to? f
          window.text[window.position.y].send f, *args, &block
        else
          super
        end
      end

      def << char
        insert(char)
      end

      def pop
        delete
      end
    end
  end
end
