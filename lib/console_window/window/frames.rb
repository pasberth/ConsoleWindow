
module ConsoleWindow

  class Window

    class Frames

      attr_accessor :window

      def initialize window
        @window = window
        @frame_procs = {}
        @frame_before_hooks = Hash.new { |hooks, frame_id| hooks[frame_id] = [] }
        @frame_after_hooks = Hash.new { |hooks, frame_id| hooks[frame_id] = [] }
        @backgrounds = []
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

      def backgrounds
        @backgrounds
      end

      def on frame_id = :main, &block
        if @frame_procs[frame_id.to_sym]
          raise(ArgumentError, "The frame id #{@window.class}->#{frame_id} was reserved.")
        else
          @frame_procs[frame_id.to_sym] = Frame.new(&block)
        end
      end

      def before frame_id, &block
        before_hooks(frame_id) << block
        true
      end

      def after frame_id, &block
        after_hooks(frame_id) << block
        true
      end

      def group frame_id
        Frames.new(@window).tap do |group|
          @frame_procs[frame_id.to_sym] ?
            raise(ArgumentError, "The frame id #{@window.class}->#{frame_id} was reserved.") :
            @frame_procs[frame_id.to_sym] = group
          yield group if block_given?
        end
      end

      def background options = {}, &block
        @backgrounds << [block, options]
      end

      def unfocus! frame_id = :main, *args, &block
        case @frame_procs[frame_id]
        when Frames
          @window.screen.active_components.unfocus(@frame_procs[frame_id], :main, *args, &block)
        else
          @window.screen.active_components.unfocus(self, frame_id, *args, &block)
        end
      end

      def focus! frame_id = :main, *args, &block
        case @frame_procs[frame_id]
        when Frames
          @window.screen.active_components.focus(@frame_procs[frame_id], :main, *args, &block)
        else
          @window.screen.active_components.focus(self, frame_id, *args, &block)
        end
      end

      def call *args, &block
        frame(:main).call(*args, &block)
      end
    end

    class Frames::Frame
      def initialize &block
        @original_block = block
        @context = Fiber.new(&block)
        @first = true
      end
      
      def call *args, &block
        if @first
          @context.resume(*args, &block)
          @first = false
        else
          begin
            @context.resume
          rescue FiberError
            initialize &@original_block
          end
        end
      end
    end
  end
end
