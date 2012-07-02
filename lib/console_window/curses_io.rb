# -*- coding: utf-8 -*-

module ConsoleWindow

  class CursesIO

    def initialize curses_window
      @curses_window = curses_window
    end

    # ====================
    # Input 
    # ====================

    # NOTE: this function is Unicode Only
    def getc
      bytes = nil
      buf = []

      while true
        case c = @curses_window.getch
        when nil
          return
        when Integer
          buf << c
        when String then
          buf += c.bytes.to_a
        end

        case buf.length
        when 1
          if 0xF8 & buf.first == 0xF0 # 4 bytes character
            bytes = 4
          elsif 0xF0 & buf.first == 0xE0 # 3 bytes character
            bytes = 3
          elsif 0xE0 & buf.first == 0xC0 # 2 bytes character
            bytes = 2
          else
            return buf.pop.chr
          end
        when 2
          next if bytes.nil? or bytes > 2
          return buf.pack("C2").encode("UTF-8", "UTF-8")
        when 3
          next if bytes.nil? or bytes > 3
          return buf.pack("C3").encode("UTF-8", "UTF-8")
        when 4
          next if bytes.nil? or bytes > 4
          return buf.pack("C4").encode("UTF-8", "UTF-8")
        else
          abort
        end
      end
    end

    def gets sep = $/
      # Curses.noecho
      ret = [].tap do |ipt|
        begin
          case c = getc
          when 127.chr  # DEL
            delc = ipt.pop or next
            case delc.bytes.count
            when 1
              @curses_window.setpos(@curses_window.cury, @curses_window.curx - 1)
              @curses_window.delch
            when 2..4
              2.times do  # 多バイト文字。とりあえず決めうちでカーソル2つ分削除。
                @curses_window.setpos(@curses_window.cury, @curses_window.curx - 1)
                @curses_window.delch
              end
            else
              abort
            end
          else
            c and @curses_window.addstr(c) # echo character. (if Curses.noecho called.)
            ipt << c
          end
        end while ipt.empty? or ipt.last and ipt.last != sep
      end

      ret.none? ? nil : ret.join
    end
  end
end
