
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'console_window'
require 'console_window/curses_window_mock'

CursesWindowMock = ConsoleWindow::CursesWindowMock
