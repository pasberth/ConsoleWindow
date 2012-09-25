module ConsoleWindow

  class Window::Out

    def initialize window
      @window = window
    end

    def write str
      @window.text.write(str)
    end
  end
end
