
require 'console_window/window'

module ConsoleWindow

  class Container < Window
    attr_accessor :components

    def as_text
      components.each do |comp|
        position.x = comp.x
        position.y = comp.y
        print_rect comp.as_text
      end
      super
    end
    
    def default_attributes
      super.merge({ :components => [] })
    end
  end
end
