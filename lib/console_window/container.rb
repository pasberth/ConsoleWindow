
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

    def displayed_lines
      text = self.text.clone
      components.each do |comp|
        text.paste!(comp.as_displayed_text, comp.x, comp.y)
      end

      h = height ? (height + scroll.y) : -1
      w = width ? (width + scroll.x) : -1
      text.crop(scroll.x, scroll.y, w, h)
    end

    def as_text
      text = self.text.clone
      components.each do |comp|
        text.paste!(comp.as_displayed_text, comp.x, comp.y)
      end

      text.as_string.chomp
    end

    def as_displayed_text
      displayed_lines.as_string.chomp
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
