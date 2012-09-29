# -*- coding: utf-8 -*-
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
          @text.overwrite!([line + [TextDisplay::DecoratedString::EMPTY]], 0, lineno + i)
        end
      end

      # FIXME: \e[5D とかの実装,
      def write str
        @text.overwrite! str, @window.position.x, @window.position.y
        lines = TextDisplay::Text.new(str).each_line.to_a
        @window.position.y += lines[0..2].length - 1
        if lines.length == 1
          @window.position.x += lines.last.length
        else
          @window.position.x = lines.last.length
        end

        str.bytes.count
      end

      def push_char char
        @text.insert! char, @window.position.x, @window.position.y
        @window.position.x += 1 # FIXME: 入力した文字数にする、 \e[1m とかは 0 文字として数える
      end

      def push_line line
        TextDisplay::Text.new(line).each_line do |line|
          @text.insert!([line], @window.position.x, @window.position.y)
          @window.position.x = 0
          @window.position.down!
        end

        self
      end

      alias << push_line

      def delete_char x, y
        @text.delete_char x, y
      end

      def delete_line no
        @text.delete_line no
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
