require 'give4each'

module ConsoleWindow

  class Window

    class Text

      include Enumerable

      attr_accessor :window

      def self.new window, text = ''
        case text
        when Text then (text.window == window) ? text : super
        else super
        end
      end

      def initialize window, text = ''
        @window = window
        @lines = case text
                 when String then text.lines.map { |line| Line.new(line) }
                 when Array then text
                 when Line then [text]
                 end
      end

      def each
        if block_given?
          @lines.each_with_index do |line, i|
            yield line ? line : @lines[i] = Line.new("\n")
          end
        else
          Enumerator.new(self, :each)
        end
      end

      def count
        @lines.length
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
          if (t = self[@window.position.y]).empty?
            @lines[@window.position.y] = t[0 .. @window.position.x] + line
          else
            @lines[@window.position.y] = t[0 .. @window.position.x] + line
            @lines.insert(@window.position.y + 1, t[@window.position.x .. t.count])
          end
          @window.position.x = 0
          @window.position.down!
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

      def displayed_text
        h = @window.height ? (@window.height + @window.scroll.y) : raise("height is nil. #{@window.inspect}")
        w = @window.width ? (@window.width + @window.scroll.x) : raise("width is nil. #{@window.inspect}")
        crop(@window.scroll.x, @window.scroll.y, w, h)
      end

      def as_string
        map(&:as_string).join
      end

      def as_displayed_string
        displayed_text.as_string
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

        def self.new line = nil
          case line
          when Line then line
          else super
          end
        end
        
        def self.parse line
          line = line.chomp
          line.split_escaped_chars
        end

        def initialize line = nil
          @null_line = [nil, ''].include? line
          @line = case line
                  when nil, '' then []
                  when Array then line.last == "\n" ? line[0..-2] : line.clone
                  when String then Line.parse(line)
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

        def count
          @line.length
        end
        
        def + line
          Line.new(to_a + Line.new(line).to_a)
        end

        def [] val
          case val
          when Range
            if val.end == 0
              Line.new("\n")
            else
              Line.new @line[val.begin .. val.end - 1]
            end
          when Integer
            @line[val]
            #return @line[val] unless @line.include? "\e"
           #
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

        def == obj
          case obj
          when String then as_string == obj
          else super
          end
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
