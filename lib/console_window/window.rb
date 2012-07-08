module ConsoleWindow

  class Window

    require 'console_window/window/lines'
    require 'console_window/window/attributes'

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

    def size
      @size ||= Size.new
    end

    def size= val
      @size = ( case val
                when Array then Size.new(*val)
                when Size then val
                else raise TypeError "Can't convert #{val.class} into #{Size}"
                end )
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

    [ :location, :Location,
      :position, :Position,
      :cursor,   :Cursor,
      :scroll,   :Scroll
    ].each_slice(2) do |attr_name, class_name|
        
      class_eval(<<-DEFINE)

          attr_reader :#{attr_name}

          def #{attr_name}= val
            @#{attr_name} = ( case val
                              when Array then #{class_name}.new(self, *val)
                              when #{class_name} then val
                              else raise TypeError "Can't convert \#{val.class} into \#{#{class_name}}"
                              end ).tap do |point|
              point.window = self
            end
          end
      DEFINE
    end

    def location
      @location or self.location = [0, 0]
    end

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
    # Curses Controllers
    # ====================

    def focus!
      screen.cursor.x = cursor.absolute_x
      screen.cursor.y = cursor.absolute_y
      screen.focus!
      true
    end

    def getc
      focus!
      screen.getc
    end

    def gets
      focus!
      screen.gets
    end
  end
end
