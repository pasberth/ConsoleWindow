require 'console_window'

screen = ConsoleWindow::Screen.new
$stdout = screen.out
screen.frames.on :main do
  puts "hello world"
  screen.getc
  screen.unfocus!
end

screen.focus!
screen.activate
