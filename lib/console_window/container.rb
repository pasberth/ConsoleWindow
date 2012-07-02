
require 'console_window/window'

module ConsoleWindow

  class Container < Window

    attr_accessor :components

    def default_attributes
      super.merge({ :components => [] })
    end

    # ====================
    # To Text Methods
    # ====================

    def as_text
      lines = self.lines
      components.each do |comp|
        lines = add_rect(comp.as_text, pos_x: comp.x, pos_y: comp.y, lines: lines)
      end

      lines.join "\n"
    end

    def as_displayed_text
      lines = self.lines
      components.each do |comp|
        lines = add_rect(comp.as_displayed_text, pos_x: comp.x, pos_y: comp.y, lines: lines)
      end

      h = height ? (height + scroll.y - 1) : -1
      w = width ? (width + scroll.x - 1) : -1
      (lines[scroll.y .. h] || []).map { |line| line ? line[scroll.x .. w] : '' }.join("\n")
    end

    # ====================
    # Container Methods
    # ====================

    def create_sub window_class, width, height, x, y, attributes = {}
      window_class.new({ owner: self, width: width, height: height, x: x, y: y }.merge(attributes))
    end

    def create_sub_window width, height, x, y, attributes = {}
      create_sub Window, width, height, x, y, attributes
    end
  end
end
