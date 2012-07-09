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


    LINENO_BAR_WIDTH = 5
    INFO_BAR_HEIGHT = 1
    CMD_LINE_HEIGHT = 1

    def initialize
      @screen = ConsoleWindow::Screen.new
      @lineno_bar = @screen.create_sub_window( LINENO_BAR_WIDTH,
                                               @screen.height -
                                               INFO_BAR_HEIGHT - CMD_LINE_HEIGHT,
                                               0,
                                               0 )

      @text_view = @screen.create_sub_window( @screen.width - LINENO_BAR_WIDTH,
                                              @screen.height -
                                              INFO_BAR_HEIGHT - CMD_LINE_HEIGHT,
                                              LINENO_BAR_WIDTH,
                                              0 )

      update_lineno

      @info_bar = @screen.create_sub_window( @screen.width,
                                             INFO_BAR_HEIGHT,
                                             0,
                                             @screen.height - CMD_LINE_HEIGHT - 1 )

      @cmd_line = @screen.create_sub_window( @screen.width,
                                             CMD_LINE_HEIGHT,
                                             0,
                                             @screen.height - 1 )

      @screen.components << @lineno_bar << @text_view << @info_bar << @cmd_line
    end

    def text_view_width
      @text_view.width
    end

    def text_view_height
      @text_view.height - 2
    end

    def activate argv = ARGV
      if argv.empty?
        STDOUT.puts "Usage: #{$0} <path>"
        return
      end
      
      load_file argv.shift
      @mode = [:normal]
      view_info
      @screen.paint
      normal_mode
    end

    def load_file filename
      if filename.nil?
        abort
      elsif File.exist? filename
        if filename != @filename
          @filename = filename
          @text_view.text = File.read(@filename).split("\n").map { |l| l.each_char.to_a }
          update_lineno
        end
      else
        @filename = filename
        @text_view.text = []
      end
    end

    def update_lineno
      (@lineno_bar.text.count .. @text_view.text.count).each do |i|
        @lineno_bar.text[i] = "%3d| " % i
      end
    end

    def view_info opts = {}
      opts = {
        mode: @mode[0].to_s,
        msg: "editing #{@filename}",
        prefix: "# "
      }.merge(opts)

      msg = opts[:msg]
      prefix = opts[:prefix]
      mode = opts[:mode]

      @info_bar.lines[0] = "#{@filename} [%s] %s%s" % [ mode, prefix, msg ]
      @screen.paint
    end

    def normal_mode
      @mode = [:normal]
      view_info mode: "normal", msg: "Type h/j/k/l, move cursor. Type 'i', change to the insert mode. Type ':', input command."
      begin
        normal_command
      end while @mode[0] == :normal
    end

    def insert_mode
      @mode = [:insert]
      view_info mode: "insert", msg: "Type any key, edit the file. Press the ESC, back to the normal mode."
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
      when "\n" then carriage_return
      when 127.chr, 'i' then insert_mode
      when ':' then
        view_info msg: "Type 'q' and the enter key, quit the application. (but will not save.) Type 'w', write into the '#{@filename}'."
        case @cmd_line.gets
        when /^wq/
          @mode = [:quit]
          File.write(@filename, @text_view.as_full_text)
        when /^q/
          @mode = [:quit]
        when /^w/
          File.write(@filename, @text_view.as_full_text)
        else
        end
      end
    end

    def scroll_left
      @text_view.cursor.left! or @text_view.scroll.left!
      @screen.paint
    end

    def scroll_down
      @text_view.cursor.down! or @text_view.scroll.down! && @lineno_bar.scroll.down!
      update_lineno
      @screen.paint
    end

    def scroll_up
      @text_view.cursor.up! or @text_view.scroll.up! && @lineno_bar.scroll.up!
      @screen.paint
    end

    def scroll_right
      @text_view.cursor.right! or @text_view.scroll.right!
      @screen.paint
    end

    def carriage_return
      scroll_down
      @text_view.cursor.x = 0
      @text_view.scroll.x = 0
      @screen.paint
    end

    def insert_command
      @text_view.position = [ @text_view.logical_cursor.x, @text_view.logical_cursor.y ]
      case char = @text_view.getc
      when 27.chr # ESC
        @screen.paint
        normal_mode
      when 127.chr # DEL
        if @text_view.logical_cursor.x > 0
          @text_view.line.pop
          scroll_left
          @screen.paint
        end
      when "\n"
        @text_view.text << "\n"
        carriage_return
        @screen.paint
      else
        @text_view.line << char
        scroll_right
        @screen.paint
      end
    end
  end
end

ConsoleWindow.start do
  editor = TextEditor::Editor.new
  editor.activate
end
