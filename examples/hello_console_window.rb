
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'console_window'

screen = ConsoleWindow::Screen.new
screen.text << "hello world"
screen.frames.on :main do
  if screen.getc
    screen.unfocus!
  end
end
screen.focus!
screen.activate
