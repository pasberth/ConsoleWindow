require 'console_window/window/movement_point'

module ConsoleWindow

  class Window::Position < Window::MovementPoint

    def min_y
      0
    end

    def min_x
      0
    end

    def max_x
      window.width - 1
    end

    def max_y
      window.height - 1
    end
  end
end
