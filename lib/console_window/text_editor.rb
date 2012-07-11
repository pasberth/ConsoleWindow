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
        when Curses::Key::RIGHT then cursor.right! or scroll.right!
        when Curses::Key::LEFT then cursor.left! or scroll.left!
        when Curses::Key::UP then cursor.up! or scroll.up!
        when Curses::Key::DOWN then cursor.down! or scroll.down!
        when 27.chr  # ESC
          unfocus!
        when 127.chr # DEL
          if cursor.left! or scroll.left!
            position.x -= 1
            current_line.pop
          end
        when "\n"
          cursor.down! or scroll.down!
          cursor.x = 0
          scroll.x = 0
          position.x = logical_cursor.x
          position.y = logical_cursor.y
          text << "\n" # TODO:  挿入の位置がおかしい。 Text#<< を修正する？
        else
          current_line << c
          cursor.right! or scroll.right!
        end
      end
    end
  end
end
