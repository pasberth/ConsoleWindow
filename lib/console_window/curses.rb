require 'curses'

module ConsoleWindow

  class Window

    # ====================
    # For the Curses Window Methods
    # ====================

    attr_accessor :curses_window

    def max_width
      curses_window ? curses_window.maxx : nil
    end

    def max_height
      curses_window ? curses_window.maxy : nil
    end

    def paint
      curses_window.clear
      curses_window.setpos 0, 0
      curses_window.addstr as_displayed_text
      curses_window.refresh
      true
    end
  end
end
