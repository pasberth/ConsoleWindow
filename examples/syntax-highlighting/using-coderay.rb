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
  puts "Usage: #{$0} <path>"
  exit
end

filename = ARGV[0]

screen = ConsoleWindow::Screen.new
screen.text = CodeRay.scan_file(filename).term
screen.frames.on :main do
  screen.getc
  screen.unfocus!
end
screen.focus!
screen.activate
