#!/usr/bin/env ruby

require 'console_window'

module TextEditor

  class Editor

    # Screen 40 * 40
    #
    #  +-- Line Number
    #  v
    # +----------------------------------------+
    # |1| hello world                          | ^
    # |2|                                      | |
    # |3|                                      | |
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ | Text View
    # | 9|                                     | |
    # |10|                                     | |
    # |11|                                     | v
    # |# hello.txt                             |   <- Information Bar
    # |%                                       |   <- Command line
    # +----------------------------------------+

    def initialize
      @screen = ConsoleWindow::Screen.new
      @text_view = @screen.create_sub_window(@screen.width, @screen.height - 1, 0, 0)
      @text_view.cursor.x = text_view_cursor_base_x
      @info_bar = @screen.create_sub_window(@screen.width, 1, 0, @screen.height - 2)
      @cmd_line = @screen.create_sub_window(@screen.width, 1, 0, @screen.height - 1)
      @screen.components << @text_view << @info_bar << @cmd_line
    end

    def text_view_cursor_base_x
      5
    end

    def text_view_width
      @text_view.width
    end

    def text_view_height
      @text_view.height - 2
    end

    def activate argv = ARGV
      load_file argv.shift
      init
      normal_mode
    end

    def load_file filename
      if filename.nil?
        abort
      elsif File.exist? filename
        if filename != @filename
          @filename = filename
          @buffer = File.read(@filename).split("\n").map { |l| l.each_char.to_a }
          @text_view.lines = @buffer.each_with_index.map { |l, i| line_format l.join, i+1 }
        end
      else
        @filename = filename
        @buffer = []
        @text_view.lines = []
      end
    end

    def line_format line, no
      "%3d| %s" % [no, line]
    end

    def init
      view_info
      @screen.paint
    end

    def view_info msg = "editing #{@filename}.", prefix = "# "
      @info_bar.lines[0] = "%s%s" % [prefix, msg]
    end

    def normal_mode
      @mode = [:normal]
      begin
        normal_command
      end while @mode[0] == :normal
    end

    def insert_mode
      @mode = [:insert]
      begin
        insert_command
      end while @mode[0] == :insert
    end

    def normal_command prompt = "% "
      @cmd_line.lines[0] = prompt
      @cmd_line.cursor.x = prompt.length
      case @text_view.getc
      when 'h' then scroll_left
      when 'j' then scroll_down
      when 'k' then scroll_up
      when 'l' then scroll_right
      when 127.chr, 'i' then insert_mode
      when ':' then 
        case @cmd_line.gets
        when /^q/
          @mode = [:quit]
        when /^w\!/
          File.write(@filename, @buffer.map(&:join).join("\n"))
        else
        end
      end
    end

    def scroll_left
      if @text_view.cursor.x - text_view_cursor_base_x > 0
        @text_view.cursor.x -= 1
      elsif @text_view.scroll.x > 0
        @text_view.scroll.x -= 1
      end
      @screen.paint
    end

    def scroll_down
      if @text_view.cursor.y < text_view_height
        @text_view.cursor.y += 1
      else
        @text_view.scroll.y += 1
      end
      @screen.paint
    end

    def scroll_up
      if @text_view.cursor.y > 0
        @text_view.cursor.y -= 1
      elsif @text_view.scroll.y > 0
        @text_view.scroll.y -= 1
      end
      @screen.paint
    end

    def scroll_right
      if @text_view.cursor.x + text_view_cursor_base_x < text_view_width
        @text_view.cursor.x += 1
      else
        @text_view.scroll.x += 1
      end
      @screen.paint
    end

    def insert_command
      case char = @text_view.getc
      when 27.chr # ESC
        @screen.paint
        normal_mode
      when 127.chr # DEL
        (@buffer[ @text_view.cursor.y ] ||= []).delete_at(@text_view.cursor.x - text_view_cursor_base_x)
        @text_view.lines[ @text_view.cursor.y ] = line_format @buffer[ @text_view.cursor.y ].join, @text_view.cursor.y + 1
        scroll_left
        @screen.paint
      else
        (@buffer[ @text_view.cursor.y ] ||= [])[ @text_view.cursor.x - text_view_cursor_base_x ] = char
        (@text_view.lines[ @text_view.cursor.y ] ||= line_format('', @text_view.cursor.y + 1))[ @text_view.cursor.x ] = char
        scroll_right
        @screen.paint
      end
    end
  end
end

begin
  Curses.init_screen
  editor = TextEditor::Editor.new
  editor.activate
ensure
  Curses.close_screen
end
