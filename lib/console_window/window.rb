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
    attr_accessor :owner

    def screen
      owner.screen
    end

    def absolute_x
      owner.absolute_x + x
    end

    def absolute_y
      owner.absolute_y + y
    end

    def default_attributes
      {
        :lines => Lines.new([]),
        :x => 0,
        :y => 0,
        # :width => nil,  # required 
        # :height => nil, # required
        :position => Position.new(0, 0),
        :cursor => Cursor.new(0, 0),
        :scroll => Scroll.new(0, 0),
        # :owner => Screen.new # required
      }
    end

    def displayed_lines
      h = height ? (height + scroll.y - 1) : -1
      w = width ? (width + scroll.x - 1) : -1
      (lines[scroll.y .. h] || []).map { |line| line[scroll.x .. w] }
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
    # Addition Methods
    # ====================

    def add_rect text, opts = {}
      opts = {
        pos_x: position.x,
        pos_y: position.y,
        lines: self.lines
      }.merge(opts)
      pos_x = opts[:pos_x]
      pos_y = opts[:pos_y]
      lines = opts[:lines].clone

      text.each_line.each_with_index do |str, i|
        str.chomp!
        l = (lines[pos_y + i] ||= '')
        if l.length < pos_x
          lines[pos_y + i] = l + (' ' * (pos_x - l.length)) + str
        else
          l[pos_x .. (str.length + pos_x - 1)] = str
        end
      end

      lines
    end

    # ====================
    # Printing Methods
    # ====================
    
    def print_rect text
      self.lines = add_rect(text)
      true
    end

    # ====================
    # Input
    # ====================

    def gets
      screen.cursor.x = absolute_x + cursor.x
      screen.cursor.y = absolute_y + cursor.y
      screen.gets
    end
  end

  Window::Lines = Array
  Window::Position = Struct.new :x, :y
  Window::Cursor = Struct.new :x, :y
  Window::Scroll = Struct.new :x, :y
end
