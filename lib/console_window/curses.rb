require 'curses'

module ConsoleWindow

  class Window

    attr_accessor :curses_window

    def paint
      curses_window.setpos 0, 0
      curses_window.addstr as_displayed_text
      curses_window.refresh
      true
    end
  end
end
