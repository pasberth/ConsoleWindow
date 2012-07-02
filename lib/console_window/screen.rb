require 'curses'
require 'console_window/container'

module ConsoleWindow

  class Screen < Container

    def default_attributes
      super.merge({ curses_window: Curses.stdscr })
    end
  end
end
