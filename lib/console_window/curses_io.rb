# -*- coding: utf-8 -*-

module ConsoleWindow

  class CursesIO

    include Curses::Key

    attr_reader :gets_buf # TODO: 

    def initialize curses_window
      @curses_window = curses_window
      @getc_buf = []
      @gets_buf = []
      @ungetc_buf = []
    end

    def write text
      @curses_window.addstr(text)
      true
    end

    def ungetc char
      @ungetc_buf << char
      nil
    end

    # ====================
    # Input 
    # ====================

    # NOTE: this function is Unicode Only
    def getc
      return @ungetc_buf.pop unless @ungetc_buf.empty?

      bytes = nil
      buf = []

      while true
        case c = @curses_window.getch
        when nil
          return  # when timeout.
        when Integer
          buf << c
        when String then
          buf += c.bytes.to_a
        end

        case buf.length
        when 1
          if  256 < buf.first            # Curses の制御文字。 Curses::Key::*** 
            # TODO: とりあえずそのまま返すがどうする?
            return buf.pop
          elsif 0xF8 & buf.first == 0xF0 # 4 bytes character
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
      begin
        case c = getc
        when nil then break # timeout
        when 127.chr  # DEL
          delc = @gets_buf.pop or next
#          case delc.bytes.count
#          when 1
#            @curses_window.setpos(@curses_window.cury, @curses_window.curx - 1)
#            @curses_window.delch
#          when 2..4
#            2.times do  # 多バイト文字。とりあえず決めうちでカーソル2つ分削除。
#              @curses_window.setpos(@curses_window.cury, @curses_window.curx - 1)
#              @curses_window.delch
#            end
#          else
#            fail
#          end
        else
          @gets_buf << c
        end
      end while @gets_buf.last != sep

      if @gets_buf.none?
        nil
      elsif @gets_buf.last == sep
        @gets_buf.join.tap do
          @gets_buf.clear
        end
      end
    end
  end
end
