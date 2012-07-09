# -*- coding: utf-8 -*-
require 'curses'
require 'console_window/container'
require 'console_window/curses_io'

module ConsoleWindow

  class Screen < Container

    def initialize *args, &block
      super
      @curses_io = CursesIO.new(curses_window)
    end

    def default_attributes
      super.merge( {
                     curses_window: Curses.stdscr,
                     owner: nil,  # Screen は常に最上位のウィンドウなので不要。 nil である前提
                     width: nil,  # width, height は Curses.stdscr によって決定される
                     height: nil  # 
                   })
    end

    # ====================
    # For the Curses Window Methods
    # ====================

    attr_accessor :curses_window
    attr_accessor :curses_io

    def screen
      self
    end

    alias absolute_x x
    alias absolute_y y

    def width
      curses_window ? curses_window.maxx : nil
    end

    def height
      curses_window ? curses_window.maxy : nil
    end

    def paint
      raise NoMethodError unless curses_window
      curses_window.clear
      as_displayed_string.each_line.with_index do |str, i| 
        curses_window.setpos i, 0
        curses_window.addstr str
      end
      focus!
      curses_window.refresh
      true
    end

    # ====================
    # Input 
    # ====================

    # NOTE: this function is Unicode Only
    def focus!
      cury = cursor.y
      curx = displayed_text[cursor.y][0 .. cursor.x].inject(0) do |i, char|
        case char.bytes.count
        when 1 then i + 1
        when 2..4 then i + 2
        else abort
        end
      end
      curses_window.setpos cury, curx
      true
    end

    def getc
      focus!
      curses_io.getc
    end

    def gets sep = $/
      focus!
      curses_io.gets(sep)
    end
  end
end
