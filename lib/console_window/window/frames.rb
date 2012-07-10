
module ConsoleWindow

  class Window

    class Frames

      def initialize window
        @window = window
        @frame_procs = {}
        @frame_before_hooks = Hash.new { |hooks, frame_id| hooks[frame_id] = [] }
        @frame_after_hooks = Hash.new { |hooks, frame_id| hooks[frame_id] = [] }        
      end

      def frame id
        @frame_procs[id.to_sym]
      end

      def before_hooks id
        @frame_before_hooks[id.to_sym]
      end

      def after_hooks id
        @frame_after_hooks[id.to_sym]
      end

      def on frame_id = :main, &block
        @frame_procs[frame_id.to_sym] ?
          raise("The frame id #{@window.class}->#{frame_id} was reserved.") : @frame_procs[frame_id.to_sym] = block
      end

      def before frame_id, &block
        before_hooks(frame_id) << block
        true
      end

      def after frame_id, &block
        after_hooks(frame_id) << block
        true
      end
    end
  end
end
