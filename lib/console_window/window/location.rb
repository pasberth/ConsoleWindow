require 'console_window/window/window_point'

module ConsoleWindow

  class Window::Location < Window::WindowPoint

    def absolute_x
      window.owner ? (window.owner.location.absolute_x + x) : x
    end

    def absolute_y
      window.owner ? (window.owner.location.absolute_y + y) : y
    end
  end
end
