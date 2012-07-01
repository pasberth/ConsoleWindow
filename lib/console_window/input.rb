# -*- coding: utf-8 -*-

module ConsoleWindow

  class Window

    # NOTE: this function is Unicode Only
    def gets sep = $/
      bytes = nil
      curx, cury = curses_window.curx, curses_window.cury
      ipt = []
      buf = []

      while ipt.last != sep
        buf << ( case c = curses_window.getch
                 when Integer then c
                 when String then c.bytes.first
                 else c
                 end )

        case buf.length
        when 1
          if 0xF8 & buf.first == 0xF0 # 4 bytes character
            bytes = 4
            next
          elsif 0xF0 & buf.first == 0xE0 # 3 bytes character
            bytes = 3
            next
          elsif 0xE0 & buf.first == 0xC0 # 2 bytes character
            bytes = 2
            next
          else
            char = buf.pop
            case char
            when 127 # DEL
              ipt.pop
            else
              ipt << char.chr
            end
          end
        when 2
          next if bytes.nil? or bytes > 2
          ipt << buf.pack("C2").encode("UTF-8", "UTF-8")
          buf.clear
        when 3
          next if bytes.nil? or bytes > 3
          ipt << buf.pack("C3").encode("UTF-8", "UTF-8")
          buf.clear
        when 4
          next if bytes.nil? or bytes > 4
          ipt << buf.pack("C4").encode("UTF-8", "UTF-8")
          buf.clear
        else
          abort
        end

        paint
        curses_window.setpos cury, curx
        curses_window.addstr ipt.join
      end

      return ipt.join
    end
  end
end
