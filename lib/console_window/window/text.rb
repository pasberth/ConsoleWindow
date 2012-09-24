require 'give4each'
require 'text_display'
require 'unicode/display_width'

module ConsoleWindow

  class Window

    class Text

      attr_accessor :window

      def self.new window, text = ''
        if Text === text and window == text.window
          text.clone
        else super
        end
      end

      def initialize window, text = ''
        @window = window
        @text = TextDisplay::Text.new(text)
      end

      def []= lineno, line
        TextDisplay::Text.new(line).each_line.with_index do |line, i|
          @text.overwrite!(line.map(&:as_string).join + "\n", 0, lineno + i)
        end
      end

      def << line
        TextDisplay::Text.new(line).each_line do |line|
          @text.insert!(line.map(&:as_string).join, @window.position.x, @window.position.y)
          @window.position.x = 0
          @window.position.down!
        end

        self
      end

      def pop
        raise  "todo"
        @text.delete_at @window.position.y
      end

      def displayed_text
        h = @window.height ? (@window.height + @window.scroll.y) : raise("height is nil. #{@window.inspect}")
        w = @window.width ? (@window.width + @window.scroll.x) : raise("width is nil. #{@window.inspect}")
        @text.crop(@window.scroll.x, @window.scroll.y, w, h)
      end

      def as_string
        @text.as_string(true)
      end

      def as_displayed_string
        displayed_text.as_string(true)
      end

      def clone
        super.instance_exec(@text.clone) do |txt|
          @text = txt
          self
        end
      end
    end
  end
end
