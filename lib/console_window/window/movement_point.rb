module ConsoleWindow

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
end
