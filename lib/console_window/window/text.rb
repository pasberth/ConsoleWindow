require 'give4each'

module ConsoleWindow

  class Window

    class Text

      include Enumerable

      attr_accessor :window

      def initialize window, text = ''
        @window = window
        @lines = case text
                 when String then text.lines.map { |line| Line.new(line) }
                 when Array then text
                 when Text then text.map(&:clone)
                 end
      end

      def each
        if block_given?
          @lines.reverse_each.drop_while(&:empty?).reverse_each.with_index do |line, i|
            yield line ? line : @lines[i] = Line.new("\n")
          end
        else
          Enumerator.new(self, :each)
        end
      end

      def []= n, text
        Text.new(@window, text).each_with_index do |line, i|
          @lines[n + i] = line
        end
      end

      def [] n
        case n
        when Integer
          @lines[n] ||= Line.new
        when Range
          Text.new(@window, @lines[n.begin .. n.end - 1] || [])
        else raise TypeError
        end
      end

      def << line
        Text.new(@window, line).each do |line|
          @lines.insert(@window.position.y, line)
          @window.position.y += 1 # TODO: replace position#down!
        end
        self
      end

      def pop
        @lines.delete_at @window.position.y
      end

      def crop start_x, start_y, end_x, end_y
        Text.new(@window, self[start_y .. end_y].map { |line| line[start_x .. end_x] })
      end

      def paste! text, x, y
        Text.new(@window, text).each_with_index do |line, i|
          self[y + i][x .. line.count + x] = line
        end
        nil
      end

      def paste *args
        clone.tap &:paste!.with(*args)
      end

      def as_string
        map(&:as_string).join
      end

      def clone
        super.instance_exec(@lines.map(&:clone)) do |lines|
          @lines = lines
          self
        end
      end
    end

    class Text

      class Line

        include Enumerable

        def initialize line = nil
          @null_line = [nil, ''].include? line
          @line = case line
                  when nil, '' then []
                  when Array then line.last == "\n" ? line[0..-2] : line.clone
                  when String then line.chomp.each_char.to_a
                  when Line then line.map(&:clone)
                  else raise TypeError, "Can't convert #{line.class} into Array"
                  end
        end

        def each
          if block_given?
            @line.each do |char|
              yield char ? char : ' '
            end
          else
            Enumerator.new(self, :each)
          end
        end
        
        def [] val
          case val
          when Range
            Line.new @line[val.begin .. val.end - 1]
          else
            raise NotImplementedError
          end
        end
        
        def []= *args
          val = Line.new(args.pop)

          case args.length
          when 1
            case args[0]
            when Integer
              @line[args[0] .. val.count] = val.to_a
            when Range
              @line[args[0].begin .. args[0].end - 1] = val.to_a
            else
              raise NotImplementedError
            end
          else
            raise NotImplementedError
          end
        end

        def insert x, char
          @line.insert x, char
        end

        def delete x
          @line.delete_at x
        end

        def empty?
          @null_line && @line.empty?
        end
        
        def as_string
          empty? ? '' : each.to_a.join + "\n"
        end

        def clone
          super.instance_exec(@line.clone) do |line|
            @line = line
            self
          end
        end
      end
    end
  end
end
