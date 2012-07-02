module ConsoleWindow

  class Window

    def initialize attributes = {}
      attributes = default_attributes.merge(attributes)
      attributes.each { |attr, val| send :"#{attr}=", val }
    end

    # ====================
    # Attribute Methods
    # ====================

    attr_accessor :lines
    attr_accessor :x
    attr_accessor :y
    attr_accessor :width
    attr_accessor :height
    attr_accessor :position
    attr_accessor :cursor
    attr_accessor :scroll

    def width
      @width ||= max_width
    end

    def height
      @height ||= max_height
    end

    def max_width
      raise NotImplementedError
    end

    def max_height
      raise NotImplementedError
    end

    def displayed_lines
      h = height ? (height + scroll.y - 1) : -1
      w = width ? (width + scroll.x - 1) : -1
      lines[scroll.y .. h].map { |line| line[scroll.x .. w] }
    end

    # ====================
    # To Text Methods
    # ====================

    def as_text
      lines.join "\n"
    end

    alias as_full_text as_text

    def as_displayed_text
      displayed_lines.join "\n"
    end

    # ====================
    # Printing Methods
    # ====================
    
    def print_rect text
      text.each_line.each_with_index do |str, i|
        str.chomp!
        l = (self.lines[position.y + i] ||= '')
        if l.length < position.x
          self.lines[position.y + i] = l + (' ' * (position.x - l.length)) + str
        else
          l[position.x .. (str.length + position.x - 1)] = str
        end
      end
    end

    def default_attributes
      {
        :lines => Lines.new([]),
        :x => 0,
        :y => 0,
        # :width => max_width,
        # :height => mac_height,
        :position => Position.new(0, 0),
        :cursor => Cursor.new(0, 0),
        :scroll => Scroll.new(0, 0)
      }
    end

    # ====================
    # For the Curses Window Methods
    # ====================

    attr_accessor :curses_window

    def max_width
      curses_window ? curses_window.maxx : nil
    end

    def max_height
      curses_window ? curses_window.maxy : nil
    end

    def paint
      curses_window.clear
      curses_window.setpos 0, 0
      curses_window.addstr as_displayed_text
      curses_window.setpos cursor.y, cursor.x
      curses_window.refresh
      true
    end

    # ====================
    # Input 
    # ====================

    # NOTE: this function is Unicode Only
    def gets sep = $/
      bytes = nil
      curx, cury = cursor.x, cursor.y
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

  Window::Lines = Array
  Window::Position = Struct.new :x, :y
  Window::Cursor = Struct.new :x, :y
  Window::Scroll = Struct.new :x, :y
end
