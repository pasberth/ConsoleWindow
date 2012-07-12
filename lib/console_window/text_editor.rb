# -*- coding: utf-8 -*-
require 'console_window'

module ConsoleWindow

  class TextEditor < Window

    def initialize *args, &block
      super

      frames.on :main do
        position.x = logical_cursor.x
        position.y = logical_cursor.y

        case c = getc
        when nil # timeout
        when Curses::Key::RIGHT then cursor.right! or scroll.right! and position.right!
        when Curses::Key::LEFT then cursor.left! or scroll.left! and position.left!
        when Curses::Key::UP then cursor.up! or scroll.up! and position.up!
        when Curses::Key::DOWN then cursor.down! or scroll.down! and position.down!
        when 27.chr  # ESC
          unfocus!
        when 127.chr # DEL
          if cursor.left! or scroll.left!
            position.x -= 1
            current_line.pop
          end
        when "\n"
          text << "\n"
          cursor.x = 0
          scroll.x = 0
          cursor.down! or scroll.down!
        else
          current_line << c
          cursor.right! or scroll.right!
        end
      end
    end
  end
end
