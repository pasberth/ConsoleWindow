# -*- coding: utf-8 -*-
require 'curses'
require 'unicode/display_width'
require 'console_window/container'
require 'console_window/text_editor'
require 'console_window/curses_io'

module ConsoleWindow

  class Screen < Container

    require 'console_window/screen/active_components'

    def initialize *args, &block
      super
      # オブジェクトを作った時点では Curses.stdscr を呼ばない。 #activate 呼び出しで初めて呼ぶ
      # @curses_window = Curses.stdscr
      # @curses_io = CursesIO.new(curses_window)
      @screen_buf = []
      @gets_window = create_sub(TextEditor, width, 1, 0, 0)
      components << @gets_window
    end

    def default_attributes
      super.merge( {
                     # curses_window: Curses.stdscr,
                     owner: nil,  # Screen は常に最上位のウィンドウなので不要。 nil である前提
                     width: nil,  # width, height は Curses.stdscr によって決定される
                     height: nil, # 
                     active_components: ActiveComponents.new(self),
                     curses: Curses
                   })
    end

    attr_accessor :active_components

    # ====================
    # For the Curses Window Methods
    # ====================

    attr_accessor :curses
    attr_accessor :curses_window
    attr_accessor :curses_io

    def screen
      self
    end

    alias absolute_x x
    alias absolute_y y

    def width
      curses_window ? curses_window.maxx : Float::INFINITY
    end

    def height
      curses_window ? curses_window.maxy : Float::INFINITY
    end

    def paint
      raise NoMethodError unless curses_window

      refresh_flag = false

      text = displayed_text
      height.times.zip(text.each_line) do |y, line|
        next unless line
        newline = line.map(&:as_string).join
        next if @screen_buf[y] == newline
        @screen_buf[y] = newline
        curses_window.setpos y, 0
        curses_io.write ' ' * width
        curses_window.setpos y, 0
        curses_io.write newline
        refresh_flag = true
      end

      if refresh_flag
        curses_window.refresh
      end
      true
    end

    def start!

      ENV["ESCDELAY"] ||= "0"

      @curses.init_screen
      @curses.start_color
      @curses.use_default_colors
      @curses.timeout = 0  # NON-BLOCKING
      @curses.noecho       # NO-ECHO
      @curses_window = @curses.stdscr
      @curses_window.keypad(true) # 

      @curses_io = CursesIO.new(curses_window)
      @curses_io.init_color(@curses)

      return unless block_given?

      begin
        yield
      ensure
        finish!
      end
    end

    def finish!
      @curses.close_screen
    end

    def loop!
      while true
        begin_time = Time.now
        @active_components.call_frame or break
        paint
        focus_cursor!
        end_time = Time.now

        # ちょうど0.02秒待機する
        # TODO: 良い名前を見つけて変数にする
        if 0 < (s = 0.01 - (end_time - begin_time))
          sleep(s)
        end
      end
    end

    def activate &main
      if block_given?
        frames.on :main, &main
        frames.focus! :main
      end
      start! do
        loop!
      end
    end

    def focus_cursor!
      if @cursor_y_current == cursor.y and
         @cursor_x_current == cursor.x
        curses_window.setpos @cury_current, @curx_current
         return
      end

      @cursor_y_current = cursor.y
      @cursor_x_current = cursor.x
      @cury_current = cursor.y
      line = displayed_text.each_line.to_a.fetch(cursor.y, [])[0, cursor.x]
      @curx_current = line.join.display_width
      if line.length < cursor.x
        @curx_current += cursor.x - line.length
      end
      curses_window.setpos @cury_current, @curx_current
      true
    end

    def getc
      begin
        case char = curses_io.getc
        when Curses::Key::RESIZE # TODO
          raise NotImplementedError
        when nil
          Fiber.yield
        else char
        end
      end until char

      char
    end

    def gets sep = $/
      @gets_window.text = ''
      @gets_window.cursor = [0, 0]
      @gets_window.position = [0, 0]
      @gets_window.location = [cursor.x, cursor.y]
      @gets_window.focus!(:main, sep)
      @gets_window.as_string
    end
  end
end
