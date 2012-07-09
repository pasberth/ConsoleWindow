module ConsoleWindow

  class Window::WindowPoint < Struct.new(:window, :x, :y)

    def absolute_x
      window.location.absolute_x + x
    end

    def absolute_y
      window.location.absolute_y + y
    end
  end
end
