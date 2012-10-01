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
      window.text.count_at(window.logical_cursor.y) + window.width - 1
    end

    def max_y
      window.text.count_lines + window.height - 1
    end
  end
end
