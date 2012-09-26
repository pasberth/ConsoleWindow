# -*- coding: utf-8 -*-

module ConsoleWindow

  class Screen

    class ActiveComponents

      Frame = Struct.new :group, :id, :args, :block
      attr_accessor :screen
      attr_reader :result

      def initialize screen
        @screen = screen
        @frame = nil
        @list = []
        @focused_list = []
        @unfocused_list = []
        @result = {}
      end

      def focused?
        ! @focused_list.empty?
      end

      def unfocused?
        ! @unfocused_list.empty?
      end

      def does_nothing?
        @list.empty?
      end

      def focus group, id, *args, &block
        @list << Frame.new(group, id, args, block)
        @focused_list << @list.last
        true
      end

      def unfocus group, id, result = { return_value: nil }
        # group(a):main
        # group(a):command
        # group(a):foo .. のようなフォーカスで unfocus(a, :main) なら :main までアンフォーカスする
        i = -1
        i-= 1 while @list[i] and
          @list[i].group == group and
          @list[i].id != id

        raise "tried to unfocus the frame '#{id}' that be not focused." unless @list[i] and @list[i].group == group and @list[i].id == id

        i.abs.times do
          @unfocused_list << @list.pop
        end

        @result = result
        true
      end

      def call_frame
        if focused?
          @frame = @focused_list.shift
          call_before_hooks
          return true
        end

        if unfocused?
          @frame = @unfocused_list.shift
          call_after_hooks
          return true
        end

        return false if does_nothing?
        raise "tried to focus the frame '#{id}' not defined." unless @frame.group.frame(@frame.id)

        @frame.group.frame(@frame.id).call(*@frame.args, &@frame.block)

        true
      end

      def call_before_hooks
        @frame.group.before_hooks(@frame.id).each &:call
      end

      def call_after_hooks
        @frame.group.after_hooks(@frame.id).each &:call
      end

      private

        def focus!
          return if @focused_list.empty?
          @screen.cursor.x = @frame.group.window.cursor.absolute_x
          @screen.cursor.y = @frame.group.window.cursor.absolute_y
        end
    end
  end
end
