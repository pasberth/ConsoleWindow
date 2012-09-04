module ConsoleWindow

  class CursesMock

    def init_screen
      @init = true; nil
    end

    def start_color
    end

    def init_color *args
    end

    def init_pair *args
    end

    def use_default_colors
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
