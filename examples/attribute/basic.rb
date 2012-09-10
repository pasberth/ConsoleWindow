
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'console_window'

screen = ConsoleWindow::Screen.new
screen.text << "\e[1m -- BOLD -- \e[m"
screen.text << "\e[4m    Underscore    \e[m"
screen.text << "\e[5m ** BLINK ** \e[m"
screen.text << "\e[7m !! REVERSE !! \e[m"
screen.text << " :: \e[8mInvisible\e[m :: "

screen.text << "\e[1m -- FOREGROUND -- \e[m"
screen.text << "Black:   \e[30m*\e[m"
screen.text << "Red:     \e[31m*\e[m"
screen.text << "Green:   \e[32m*\e[m"
screen.text << "Yellow:  \e[33m*\e[m"
screen.text << "Blue:    \e[34m*\e[m"
screen.text << "Magenta: \e[35m*\e[m"
screen.text << "Cyan:    \e[36m*\e[m"
screen.text << "White:   \e[37m*\e[m"

screen.text << "\e[1m -- BACKGROUND -- \e[m"
screen.text << "Black:   \e[40m*\e[m"
screen.text << "Red:     \e[41m*\e[m"
screen.text << "Green:   \e[42m*\e[m"
screen.text << "Yellow:  \e[43m*\e[m"
screen.text << "Blue:    \e[44m*\e[m"
screen.text << "Magenta: \e[45m*\e[m"
screen.text << "Cyan:    \e[46m*\e[m"
screen.text << "White:   \e[47m*\e[m"

screen.text << "\e[1m -- Fg/Bg -- \e[m"
screen.text << "Black/White:  \e[30;47m*\e[m"
screen.text << "White/Red:    \e[37;41m*\e[m"
screen.text << "Black/Yellow: \e[30;43m*\e[m"

screen.frames.on :main do
  screen.getc
  screen.unfocus!
end
screen.focus!
screen.activate
