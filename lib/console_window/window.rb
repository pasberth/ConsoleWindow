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

    def location
      @location or self.location = Location.new(self, 0, 0)
    end

    def location= l
      @location = l.tap do |l|
        l.window = self
      end
    end

    [ :x,
      :y,
      :absolute_x,
      :absolute_y
    ].each do |a|
      class_eval(<<-A)
        def #{a}                # def x
          location.#{a}         #   location.x
        end                     # end

        def #{a}= val           # def x= val
          location.#{a} = val   #   location.x = val
        end                     # end
      A
    end

    attr_accessor :size

    def size
      @size ||= Size.new
    end

    [:width, :height].each do |a|
      class_eval(<<-A)
        def #{a}            # def width
          size.#{a}         #   size.width
        end                 # end

        def #{a}= val       # def width= val
          size.#{a} = val   #   size.width = val
        end                 # end
      A
    end

    attr_accessor :position
    attr_accessor :cursor
    attr_accessor :scroll


    attr_accessor :owner

    def screen
      owner.screen
    end

    def default_attributes
      {
        :lines => Lines.new([]),
        :location => Location.new(self, 0, 0),
        :size => Size.new(nil, nil),
        :x => 0,
        :y => 0,
        # :width => nil,  # required 
        # :height => nil, # required
        :position => Position.new(self, 0, 0),
        :cursor => Cursor.new(self, 0, 0),
        :scroll => Scroll.new(self, 0, 0),
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
      screen.cursor.x = cursor.absolute_x
      screen.cursor.y = cursor.absolute_y
      screen.gets
    end
  end

  Window::Lines = Array

  class Window::WindowPoint < Struct.new(:window, :x, :y)

    def absolute_x
      window.location.absolute_x + x
    end

    def absolute_y
      window.location.absolute_y + y
    end
  end

  class Window::Location < Window::WindowPoint

    def absolute_x
      window.owner ? (window.owner.location.absolute_x + x) : x
    end

    def absolute_y
      window.owner ? (window.owner.location.absolute_y + y) : y
    end
  end

  Window::Size = Struct.new :width, :height
  class Window::Position < Window::WindowPoint; end
  class Window::Cursor < Window::WindowPoint; end
  class Window::Scroll < Window::WindowPoint; end
end
