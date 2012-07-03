module ConsoleWindow

  class Window::WindowPoint < Struct.new(:window, :x, :y)

    def absolute_x
      window.location.absolute_x + x
    end

    def absolute_y
      window.location.absolute_y + y
    end
  end

  class Window::Location < Window::WindowPoint

    def absolute_x
      window.owner ? (window.owner.location.absolute_x + x) : x
    end

    def absolute_y
      window.owner ? (window.owner.location.absolute_y + y) : y
    end
  end

  Window::Size = Struct.new :width, :height
  class Window::Position < Window::WindowPoint; end
  class Window::Cursor < Window::WindowPoint; end
  class Window::Scroll < Window::WindowPoint; end
end
