# -*- coding: utf-8 -*-

module ConsoleWindow

  class Screen

    class ActiveComponents

      attr_accessor :screen
      attr_accessor :list

      def initialize screen, list = []
        @screen = screen
        @list = list
        @result = {}
      end

      attr_reader :result

      def frame_group
        @list.last ? @list.last[0] : nil
      end

      def frame_id
        @list.last ? @list.last[1] : nil
      end

      def frame_args
        @list.last ? @list.last[2] : nil
      end

      def frame_block
        @list.last ? @list.last[3] : nil
      end

      def focus group, id, *args, &block
        @list << [group, id, args, block]
        focus!
        true
      end

      def unfocus group, id, result = { return_value: nil }
        return false if self.frame_group != group
        # group(a):main
        # group(a):command
        # group(a):foo .. のようなフォーカスで unfocus(a, :main) なら :main までアンフォーカスする

        # TODO: この実装だと after が呼ばれない。
        while self.frame_id != id
          @list.pop
        end
        @list.pop
        focus!
        @result = result
        true
      end

      private

        def focus!
          return if @list.empty?
          @screen.cursor.x = frame_group.window.cursor.absolute_x
          @screen.cursor.y = frame_group.window.cursor.absolute_y
        end
    end
  end
end
