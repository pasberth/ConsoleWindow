require 'curses'
require 'console_window/container'
require 'console_window/curses_io'

module ConsoleWindow

  class Screen < Container

    def initialize *args, &block
      super
      @curses_io = CursesIO.new(curses_window)
    end

    def default_attributes
      super.merge({ curses_window: Curses.stdscr })
    end

    # ====================
    # For the Curses Window Methods
    # ====================

    attr_accessor :curses_window
    attr_accessor :curses_io

    def screen
      self
    end

    alias absolute_x x
    alias absolute_y y

    def width
      curses_window ? curses_window.maxx : nil
    end

    def height
      curses_window ? curses_window.maxy : nil
    end

    def paint
      raise NoMethodError unless curses_window
      curses_window.clear
      curses_window.setpos 0, 0
      curses_window.addstr as_displayed_text
      curses_window.setpos cursor.y, cursor.x
      curses_window.refresh
      true
    end

    # ====================
    # Input 
    # ====================

    # NOTE: this function is Unicode Only

    def getc
      curses_window.setpos cursor.y, cursor.x
      curses_io.getc
    end

    def gets sep = $/
      curses_window.setpos cursor.y, cursor.x
      curses_io.gets(sep)
    end
  end
end
