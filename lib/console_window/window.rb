# -*- coding: utf-8 -*-
module ConsoleWindow

  class Window

    require 'console_window/window/text'
    require 'console_window/window/attributes'

    def initialize attributes = {}
      attributes = default_attributes.merge(attributes)
      attributes.each { |attr, val| send :"#{attr}=", val }
    end

    # ====================
    # Attribute Methods
    # ====================

    attr_accessor :text

    def line
      @text[position.y]
    end

    def line= line
      @text[position.y] = line
    end

    def text= text
      @text = Text.new(self, text)
    end

    alias lines text
    alias lines= text=

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

    attr_reader :logical_cursor

    def logical_cursor= val
      # 最初の一度だけ代入可能
      @logical_cursor ? raise(NoMethodError) : @logical_cursor = val
    end

    attr_accessor :owner

    def screen
      owner.screen
    end

    def default_attributes
      {
        :text => Text.new(self, []),
        :location => Location.new(self, 0, 0),
        :size => Size.new(nil, nil),
        :x => 0,
        :y => 0,
        # :width => nil,  # required 
        # :height => nil, # required
        :position => Position.new(self, 0, 0),
        :cursor => Cursor.new(self, 0, 0),
        :scroll => Scroll.new(self, 0, 0),
        :logical_cursor => LogicalCursor.new(self)
        # :owner => Screen.new # required
      }
    end

    def displayed_lines
      h = height ? (height + scroll.y) : -1
      w = width ? (width + scroll.x) : -1
      text.crop(scroll.x, scroll.y, w, h)
    end

    # ====================
    # To Text Methods
    # ====================

    def as_text
      text.to_s.chomp
    end

    alias as_full_text as_text

    def as_displayed_text
      displayed_lines.to_s.chomp
    end

    # ====================
    # Printing Methods
    # ====================
    
    def print_rect text
      self.text = self.text.paste(text, position.x, position.y)
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
