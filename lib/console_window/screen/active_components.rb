
module ConsoleWindow

  class Screen

    class ActiveComponents

      attr_accessor :screen
      attr_accessor :list

      def initialize screen, list = []
        @screen = screen
        @list = list
      end

      def focused_window
        @list.last ? @list.last[0] : nil
      end

      def frame_id
        @list.last ? @list.last[1] : nil
      end

      def focus comp, frame_id
        @list << [comp, frame_id.to_sym]
        focus!
        true
      end

      def unfocus comp, frame_id
        return false if focused_window != comp or self.frame_id != frame_id
        @list.pop
        focus!
        true
      end

      private

        def focus!
          return if @list.empty?
          @screen.cursor.x = focused_window.cursor.absolute_x
          @screen.cursor.y = focused_window.cursor.absolute_y
        end
    end
  end
end
