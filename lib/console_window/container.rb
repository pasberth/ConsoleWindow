
require 'console_window/window'

module ConsoleWindow

  class Container < Window
    attr_accessor :components

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
      (lines[scroll.y .. h] || []).map { |line| line[scroll.x .. w] }.join("\n")
    end
    
    def default_attributes
      super.merge({ :components => [] })
    end
  end
end
