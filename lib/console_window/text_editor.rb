require 'console_window'

module ConsoleWindow

  class TextEditor < Window

    def initialize *args, &block
      super

      frames.on :main do
        position.x = logical_cursor.x
        position.y = logical_cursor.y

        case c = getc
        when 27.chr  # ESC
          unfocus!
        when 127.chr # DEL
          if cursor.left! or scroll.left!
            position.x -= 1
            current_line.pop
          end
        when "\n"
          scroll.down!
          cursor.x = 0
          scroll.x = 0
          text << "\n"
        else
          current_line << c
          cursor.right! or scroll.right!
        end
      end
    end
  end
end
