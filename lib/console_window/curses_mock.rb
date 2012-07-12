module ConsoleWindow

  class CursesMock

    def init_screen
      @init = true; nil
    end

    def close_screen
      @close = true; nil
    end

    def timeout= delay
    end

    def echo
    end

    def noecho
    end
  end
end
