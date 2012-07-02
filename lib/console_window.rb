
module ConsoleWindow
  require 'console_window/window'
  require 'console_window/container'
  require 'console_window/screen'

  def self.start
    Curses.init_screen
    Curses.noecho
    yield if block_given?
  ensure
    Curses.close_screen
  end
end
