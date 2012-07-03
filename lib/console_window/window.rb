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

    def lines= lines
      @lines = case lines
               when Array then Lines.new(lines)
               when Lines then lines
               else raise TypeError, "Can't convert #{lines.class} into #{Lines}"
               end
    end

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
      Lines.new lines[scroll.y .. h].map { |line| line[scroll.x .. w] }
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

      text.split("\n").each_with_index do |str, i|
        lines[pos_y + i][pos_x .. (str.length + pos_x - 1)] = str.each_char.to_a
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

    def getc
      screen.cursor.x = cursor.absolute_x
      screen.cursor.y = cursor.absolute_y
      screen.getc
    end

    def gets
      screen.cursor.x = cursor.absolute_x
      screen.cursor.y = cursor.absolute_y
      screen.gets
    end
  end

  class Window::Line

    include Enumerable

    def initialize line = []
      @line = line
    end

    def method_missing f, *args, &block
      @line.respond_to?(f) ? @line.send(f, *args, &block) : super
    end

    [:==].each do |m|
      class_eval(<<-DEFINE)
          def #{m}(*args, &block)
            @line.send(:#{m}, *args, &block)
          end
        DEFINE
    end

    def to_s
      map { |l| l ? l.to_s : ' ' }.join
    end
  end

  class Window::Lines

    include Enumerable

    def initialize lines = []
      @lines = lines
    end

    def method_missing f, *args, &block
      @lines.respond_to?(f) ? @lines.send(f, *args, &block) : super
    end

    [:==].each do |m|
      class_eval(<<-DEFINE)
          def #{m}(*args, &block)
            @lines.send(:#{m}, *args, &block)
          end
        DEFINE
    end

    def each
      if block_given?
        length.times { |i| yield self[i] }
        self
      else
        Enumerator.new(self, :each)
      end
    end

    def [] *args, &block
      case args.count
      when 1
        case args[-1]
        when Range
          case lines = @lines[*args]
          when Array then Window::Lines.new(lines)
          else lines
          end
        else
          case line = @lines[*args]
          when Window::Line then line
          when String then self[*args] = Window::Line.new(line.each_char.to_a)
          when Array then self[*args] = Window::Line.new(line)
          when nil then self[*args] = Window::Line.new([])
          else line
          end
        end
      else @lines[*args]
      end
    end

    def join *args
      map(&:to_s).join(*args)
    end
  end

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
