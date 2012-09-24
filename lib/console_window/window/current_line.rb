require 'console_window/window/text'

module ConsoleWindow

  class Window

    class CurrentLine

      attr_accessor :window

      def initialize window
        @window = window
      end
      
      def << char
        @window.text.push_char(char)
      end

      def pop
        @window.text.delete_char(@window.position.y)
      end

      def delete!
        @window.text.delete_line(@window.position.y)
      end
    end
  end
end
