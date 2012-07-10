# -*- coding: utf-8 -*-
require 'curses'
require 'console_window/container'
require 'console_window/curses_io'

module ConsoleWindow

  class Screen < Container

    require 'console_window/screen/active_components'

    def initialize *args, &block
      super
      # オブジェクトを作った時点では Curses.stdscr を呼ばない。 #activate 呼び出しで初めて呼ぶ
      # @curses_window = Curses.stdscr
      # @curses_io = CursesIO.new(curses_window)
    end

    def default_attributes
      super.merge( {
                     # curses_window: Curses.stdscr,
                     owner: nil,  # Screen は常に最上位のウィンドウなので不要。 nil である前提
                     width: nil,  # width, height は Curses.stdscr によって決定される
                     height: nil, # 
                     active_components: ActiveComponents.new(self, [])
                   })
    end

    attr_accessor :active_components

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
      cursor.y = @active_components.focused_window.cursor.absolute_y
      cursor.x = @active_components.focused_window.cursor.absolute_x
      focus_cursor!
      curses_window.refresh
      true
    end

    def activate
      Curses.init_screen
      Curses.noecho

      @curses_window = Curses.stdscr
      @curses_io = CursesIO.new(curses_window)

      while @active_components.focused_window
        paint
        id = @active_components.frame_id
        @active_components.focused_window.frames.before_hooks(id).each &:call
        paint
        @active_components.focused_window.frames.frame(id).call
        paint
        @active_components.focused_window.frames.after_hooks(id).each &:call
      end

    ensure
      Curses.close_screen
    end

    def focus_cursor!
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
      focus_cursor!
      curses_io.getc
    end

    def gets sep = $/
      focus_cursor!
      curses_io.gets(sep)
    end
  end
end
