# -*- coding: utf-8 -*-
module ConsoleWindow

  class Window

    require 'console_window/window/text'
    require 'console_window/window/current_line'
    require 'console_window/window/location'
    require 'console_window/window/size'
    require 'console_window/window/position'
    require 'console_window/window/cursor'
    require 'console_window/window/scroll'
    require 'console_window/window/logical_cursor'
    require 'console_window/window/frames'

    REQUIRED = Object.new

    def initialize attributes = {}
      attributes = default_attributes.merge(attributes)
      raise "Required attribtues (%s) by #{self.class} was not given." % attributes.select{|a,v| REQUIRED == v }.map{|k,v|k}.join(", ") if attributes.each_value.any? { |v| REQUIRED == v }
      attributes.each { |attr, val| send :"#{attr}=", val }
    end

    # ====================
    # Attribute Methods
    # ====================

    def default_attributes
      {
        text:           Text.new(self, []),
        current_line:   CurrentLine.new(self),
        location:       Location.new(self, 0, 0),
        size:           Size.new(self, nil, nil),
        x:              0,
        y:              0,
        width:          REQUIRED,
        height:         REQUIRED,
        position:       Position.new(self, 0, 0),
        cursor:         Cursor.new(self, 0, 0),
        scroll:         Scroll.new(self, 0, 0),
        logical_cursor: LogicalCursor.new(self),
        frames:         Frames.new(self),
        owner:          REQUIRED
      }
    end

    attr_accessor :text
    attr_accessor :current_line

    def current_line= line
      case line
      when CurrentLine then @current_line = line
      else
        @text[position.y] = line
      end
    end

    def text= text
      @text = Text.new(self, text)
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
      @size ||= Size.new(self)
    end

    def size= val
      @size = ( case val
                when Array then Size.new(self, *val)
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

    attr_accessor :frames
    attr_accessor :owner

    def screen
      owner.screen
    end

    def as_string
      text.as_string.chomp
    end

    def as_displayed_string
      text.as_displayed_string.chomp
    end

    # ====================
    # Curses Controllers
    # ====================

    def unfocus! frame_id = :main
      screen.active_components.unfocus self, frame_id
    end

    def focus! frame_id = :main
      screen.active_components.focus self, frame_id
    end

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
end
