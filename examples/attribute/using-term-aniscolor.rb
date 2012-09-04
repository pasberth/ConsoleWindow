$:.unshift File.dirname(__FILE__) + '/../../lib'
require 'console_window'

begin
  require 'term/ansicolor'
rescue LoadError
  puts <<-MSG
"#$0" requires Term::ANSIColor module but not exists.

Run the following command, and try running this program again:
    $ gem install term-ansicolor
  MSG
end

include Term::ANSIColor

screen = ConsoleWindow::Screen.new
screen.text << bold(" -- BOLD -- ")
screen.text << underscore("   Underscore   ")
screen.text << blink(" ** BLINK ** ")
screen.text << negative(" !! REVERSE !! ")
screen.text << concealed(" :: Invisible :: ")

screen.text << bold(" -- FOREGROUND -- ")
screen.text << "Black:   %s" % black('*')
screen.text << "Red:     %s" % red('*')
screen.text << "Green:   %s" % green('*')
screen.text << "Yellow:  %s" % yellow('*')
screen.text << "Blue:    %s" % blue('*')
screen.text << "Magenta: %s" % magenta('*')
screen.text << "Cyan:    %s" % cyan('*')
screen.text << "White:   %s" % white('*')

screen.text << bold(" -- BACKGROUND -- ")
screen.text << "Black:   %s" % on_black('*')
screen.text << "Red:     %s" % on_red('*')
screen.text << "Green:   %s" % on_green('*')
screen.text << "Yellow:  %s" % on_yellow('*')
screen.text << "Blue:    %s" % on_blue('*')
screen.text << "Magenta: %s" % on_magenta('*')
screen.text << "Cyan:    %s" % on_cyan('*')
screen.text << "White:   %s" % on_white('*')

screen.text << bold(" -- Fg/Bg -- ")
screen.text << "Black/White:  %s" % black { on_white "*" }
screen.text << "White/Red:    %s" % white { on_red "*" }
screen.text << "Black/Yellow: %s" % black { on_yellow "*" }

screen.frames.on :main do
  if screen.getc
    screen.unfocus!
  end
end
screen.focus!
screen.activate
