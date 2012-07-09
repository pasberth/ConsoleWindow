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

  class Window::MovementPoint < Window::WindowPoint

    def up!
      self.y > min_y ? (self.y -= 1; true) : false
    end

    def left!
      self.x > min_x ? (self.x -= 1; true) : false
    end

    def right!
      self.x < max_x ? (self.x += 1; true) : false
    end

    def down!
      self.y < max_y ? (self.y += 1; true) : false
    end
  end

  class Window::Cursor < Window::MovementPoint

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

  class Window::Scroll < Window::MovementPoint


    def min_y
      0
    end

    def min_x
      0
    end

    def max_x
      window.lines[window.logical_cursor.y].length + window.width - 1
    end

    def max_y
      window.lines.length + window.height - 1
    end
  end

  class Window::LogicalCursor < Struct.new :window

    def x
      window.cursor.x + window.scroll.x
    end

    def y
      window.cursor.y + window.scroll.y
    end
  end
end
