require 'text_display'
require 'console_window/window'

module ConsoleWindow

  class Container < Window

    require 'console_window/container/components'

    attr_accessor :components

    def default_attributes
      super.merge({ :components => Components.new(self, []) })
    end

    # ====================
    # To Text Methods
    # ====================

    def displayed_text
      text = self.text.instance_variable_get(:@text).clone
      components.each do |comp|
        text.paste!(comp.displayed_text, comp.x, comp.y)
      end
      Window::Text.new(self, text).displayed_text
    end

    def as_string
      displayed_text.as_string(true).chomp
    end

    alias as_displayed_string as_string

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
