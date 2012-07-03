
module ConsoleWindow

  class Window

    class Line

      include Enumerable
      
      def initialize line = []
        @line = line
      end
      
      def method_missing f, *args, &block
        @line.respond_to?(f) ? @line.send(f, *args, &block) : super
      end
      
      [:==].each do |m|
        class_eval(<<-DEFINE)
          def #{m}(*args, &block)
            @line.send(:#{m}, *args, &block)
          end
        DEFINE
      end
      
      def to_s
        map { |l| l ? l.to_s : ' ' }.join
      end
    end
    
    class Lines
      
      include Enumerable
      
      def initialize lines = []
        @lines = lines
      end
      
      def method_missing f, *args, &block
        @lines.respond_to?(f) ? @lines.send(f, *args, &block) : super
      end
      
      [:==].each do |m|
        class_eval(<<-DEFINE)
          def #{m}(*args, &block)
            @lines.send(:#{m}, *args, &block)
          end
        DEFINE
      end

      def each
        if block_given?
          length.times { |i| yield self[i] }
          self
        else
          Enumerator.new(self, :each)
        end
      end
      
      def [] *args, &block
        case args.count
        when 1
          case args[-1]
          when Range
            case lines = @lines[*args]
            when Array then Lines.new(lines)
            else lines
            end
          else
            case line = @lines[*args]
            when Line then line
            when String then self[*args] = Line.new(line.each_char.to_a)
            when Array then self[*args] = Line.new(line)
            when nil then self[*args] = Line.new([])
            else line
            end
          end
        else @lines[*args]
        end
      end
      
      def join *args
        map(&:to_s).join(*args)
      end
    end
  end
end
