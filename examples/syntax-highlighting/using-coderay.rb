$:.unshift File.dirname(__FILE__) + '/../../lib'
require 'console_window'

begin
  require 'coderay'
rescue LoadError
  puts <<-MSG
"#$0" requires CodeRay module but not exists.

Run the following command, and try running this program again:
    $ gem install coderay
  MSG
end

if ARGV.empty?
  filename = __FILE__
else
  filename = ARGV[0]
end

screen = ConsoleWindow::Screen.new
screen.text = CodeRay.scan_file(filename).term
screen.frames.on :main do
  screen.getc
  screen.unfocus!
end
screen.focus!
screen.activate
