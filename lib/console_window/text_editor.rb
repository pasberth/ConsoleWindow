# -*- coding: utf-8 -*-
require 'console_window'

module ConsoleWindow

  class TextEditor < Window

    def initialize *args, &block
      super

      frames.on :main do |sep=27.chr| # ESC
        position.x = logical_cursor.x
        position.y = logical_cursor.y

        case c = getc
        when Curses::Key::RIGHT then
          if logical_cursor.x < current_line.count
            cursor.right! or scroll.right! and position.right!
          end
        when Curses::Key::LEFT then cursor.left! or scroll.left! and position.left!
        when Curses::Key::UP then cursor.up! or scroll.up! and position.up!
        when Curses::Key::DOWN
          if logical_cursor.y + 1 < text.count_lines
            cursor.down! or scroll.down! and position.down!
            if current_line.count <= logical_cursor.x
              cursor.x = current_line.count - scroll.x
            end
          end
        when sep
          unfocus!
        when Curses::Key::BACKSPACE, 127.chr # DEL
          if cursor.left! or scroll.left!
            position.left!
            current_line.pop
          else
            if cursor.up! or scroll.up!
              del = text.pop
              position.up!
              if cursor.max_x < current_line.count
                cursor.x = cursor.max_x
                scroll.x = current_line.count - cursor.max_x
              else
                cursor.x = current_line.count
              end
              text[position.y] = current_line + del
            end
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
