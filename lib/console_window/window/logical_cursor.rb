module ConsoleWindow

  class Window::LogicalCursor < Struct.new :window

    def x
      window.cursor.x + window.scroll.x
    end

    def y
      window.cursor.y + window.scroll.y
    end
  end
end
