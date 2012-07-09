require 'console_window/window/movement_point'

module ConsoleWindow

  class Window::Scroll < Window::MovementPoint


    def min_y
      0
    end

    def min_x
      0
    end

    def max_x
      window.text[window.logical_cursor.y].count + window.width - 1
    end

    def max_y
      window.text.count + window.height - 1
    end
  end
end
