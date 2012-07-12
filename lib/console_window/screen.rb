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
                     active_components: ActiveComponents.new(self, []),
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
      focus_cursor!
      curses_window.addstr(curses_io.gets_buf.join) # echo. TODO: gets_buf のもっと良い名前
      curses_window.refresh
      true
    end

    def activate
      @curses.init_screen
      @curses.timeout = 0  # NON-BLOCKING
      @curses.noecho       # NO-ECHO
      @curses_window = @curses.stdscr
      @curses_window.keypad(true) # 

      @curses_io = CursesIO.new(curses_window)

      before_id = nil
      before_window = nil

      begin
        begin_time = Time.now

        window = @active_components.focused_window
        id     = @active_components.frame_id
        args   = @active_components.frame_args
        block  = @active_components.frame_block

        # フォーカスが移動した瞬間の処理
        # 処理順:
        # in frame(A) -> before_hooks(A) -> frame(A)-loop -> break frame(A)
        # -> in frame(B) -> after_hooks(A) -> frame(B)-loop -> break frame(B)
        # -> ...
        # before や after 内でフォーカスを変えたら、
        # frame-loop は一度もしないが before と after は必ず呼ばれる

        if window != before_window or id != before_id
          before_window.frames.after_hooks(before_id).each &:call if before_window
          window.frames.before_hooks(id).each &:call  if window
          before_window = window
          before_id = id
          next # before や after 内でフォーカスが変えられた場合、frame(id) は呼ばれない
        end

        break unless window

        raise "tried to focus the frame '#{id}' not defined." unless window.frames.frame(id)

        window.frames.frame(id).call(*args, &block)

        components.each { |comp| comp.frames.backgrounds.each { |frame, opts| frame.call } }

        end_time = Time.now

        # ちょうど0.02秒待機する
        # TODO: 良い名前を見つけて変数にする
        if 0 < (s = 0.02 - (end_time - begin_time))
          sleep(s)
        end

        paint
      end while window

    ensure
      @curses.close_screen
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
      case c = curses_io.getc
      when Curses::Key::RESIZE # TODO
        raise NotImplementedError
      else
        c
      end
    end

    def gets sep = $/
      curses_io.gets(sep)
    end
  end
end
