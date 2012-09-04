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
      @screen_buf = []
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

      refresh_flag = false

      text = displayed_text
      height.times.zip text do |y, line|
        line ||= []
        if @screen_buf[y] != (newline = line.to_a.join)
          @screen_buf[y] = newline
          refresh_flag ||= true
          break
        end
      end

      if refresh_flag
        curses_window.clear

        on_attrs = []

        attron = lambda do |a|
          on_attrs << a
          case a
          when 1 then curses_window.attron(Curses::A_BOLD)
          when 4 then curses_window.attron(Curses::A_UNDERLINE)
          when 5 then curses_window.attron(Curses::A_BLINK)
          when 7 then curses_window.attron(Curses::A_STANDOUT)
          end
        end

        attroff = lambda do |a|
          on_attrs.delete(a)
          case a
          when 1 then curses_window.attroff(Curses::A_BOLD)
          when 4 then curses_window.attroff(Curses::A_UNDERLINE)
          when 5 then curses_window.attroff(Curses::A_BLINK)
          when 7 then curses_window.attroff(Curses::A_STANDOUT)
          end
        end

        attroff_all = lambda do
          on_attrs.each { |a| attroff.call(a) }
        end

        height.times.zip text do |y, line|
          line ||= []
          curses_window.setpos y, 0
          line.each do |c|
            case c
            when "\e[m", "\e[0m"
              attroff_all.call()
              #curses_window.attroff(Curses::A_BOLD)
            when /^\e\[(?<A>\d*)(?<COL>;\d+\g<COL>?)?m/
              a, col = $1.to_i, $2
              attron.call(a)
              col and col.split(';').map(&:to_i).each { |a| attron(a) }
            else
              curses_window.addch c
            end
          end
        end
      end

      focus_cursor!
      curses_window.addstr(curses_io.gets_buf.join) # echo. TODO: gets_buf のもっと良い名前

      if refresh_flag
        curses_window.refresh
      end
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
      before_group = nil

      begin
        begin_time = Time.now

        group  = @active_components.frame_group
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

        if group != before_group or id != before_id
          before_group.after_hooks(before_id).each &:call if before_group
          group.before_hooks(id).each &:call  if group
          before_group = group
          before_id = id
          next # before や after 内でフォーカスが変えられた場合、frame(id) は呼ばれない
        end

        break unless group

        raise "tried to focus the frame '#{id}' not defined." unless group.frame(id)

        group.frame(id).call(*args, &block)

        # TODO: deep calling
        components.each { |comp| comp.frames.backgrounds.each { |frame, opts| frame.call } }

        paint

        end_time = Time.now

        # ちょうど0.02秒待機する
        # TODO: 良い名前を見つけて変数にする
        if 0 < (s = 0.01 - (end_time - begin_time))
          sleep(s)
        end
      end while group

    ensure
      @curses.close_screen
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
      @curx_current = displayed_text[cursor.y][0 .. cursor.x].inject(0) do |i, char|
        case char.bytes.count
        when 1 then i + 1
        when 2..4 then i + 2
        else abort
        end
      end
      curses_window.setpos @cury_current, @curx_current
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
