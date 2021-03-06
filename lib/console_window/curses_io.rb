# -*- coding: utf-8 -*-

module ConsoleWindow

  class CursesIO

    include Curses::Key

    attr_reader :gets_buf # TODO: 

    def initialize curses_window
      @curses_window = curses_window
      @attrs = [] 
      @color_pair = [38, 48]
      @getc_buf = []
      @gets_buf = []
      @ungetc_buf = []
    end

    def write text
      text.each_escaped_char do |c|
        case c
        when "\e[m", "\e[0m"
          attroff_all
        when /^\e\[(?<A>\d*)(?<COL>;\d+\g<COL>?)?m/
          a, col = $1.to_i, $2
          attron(a)
          col and col.split(';').map(&:to_i).each { |a| attron(a) }
        else
          @curses_window.addstr c
        end
      end
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


    def init_color(curses=Curses)
      (30..38).each do |fg|
        (40..48).each do |bg|
          curses.init_pair(color_pair_id(fg, bg), ansi_color_to_curses_color(fg), ansi_color_to_curses_color(bg))
        end
      end
    end


    private

      def ansi_color_to_curses_attr n
        case n
        when 1 then Curses::A_BOLD
        when 4 then Curses::A_UNDERLINE
        when 5 then Curses::A_BLINK
        when 7 then Curses::A_STANDOUT
        when 8 then Curses::A_INVIS
        when 30..38, 40..48 then Curses.color_pair(current_color_pair_id)
        else nil
        end
      end

      def ansi_color_to_curses_color n
        case n
        when 30, 40 then Curses::COLOR_BLACK
        when 31, 41 then Curses::COLOR_RED
        when 32, 42 then Curses::COLOR_GREEN
        when 33, 43 then Curses::COLOR_YELLOW
        when 34, 44 then Curses::COLOR_BLUE
        when 35, 45 then Curses::COLOR_MAGENTA
        when 36, 46 then Curses::COLOR_CYAN
        when 37, 47 then Curses::COLOR_WHITE
        when 38, 48 then -1 # -1 でターミナルのデフォルトの色にできる
        end
      end

      def color_pair_id fg, bg
        fg = fg - 30
        bg = bg - 40
        fg + bg*9
      end

      def current_color_pair_id
        color_pair_id(*@color_pair)
      end

      def attron a
        case a
        when 30..38
          @color_pair[0] = a
        when 40..48
          @color_pair[1] = a
        else
          @attrs << a
        end

        curses_attr = ansi_color_to_curses_attr(a) or return

        @curses_window.attron curses_attr
        true
      end

      def attroff a
        case a
        when 30..38
          curses_attr = Curses::A_COLOR
          @color_pair[0] = 38
        when 40..48
          curses_attr = Curses::A_COLOR
          @color_pair[1] = 48
        else
          curses_attr = ansi_color_to_curses_attr(a) or return
          @attrs.delete(a) or return
        end

        @curses_window.attroff curses_attr
        true
      end

      def attroff_all
        @attrs.each { |a| attroff(a) }
        @color_pair.each { |a| attroff(a) }
        true
      end
  end
end
