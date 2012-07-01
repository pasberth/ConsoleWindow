module ConsoleWindow

  class Window

    def initialize attributes = {}
      attributes = default_attributes.merge(attributes)
      attributes.each { |attr, val| send :"#{attr}=", val }
    end

    # ====================
    # Attribute Methods
    # ====================

    attr_accessor :lines
    attr_accessor :width
    attr_accessor :height
    attr_accessor :scroll

    def width
      @width ||= max_width
    end

    def height
      @height ||= max_height
    end

    def max_width
      raise NotImplementedError
    end

    def max_height
      raise NotImplementedError
    end

    def displayed_lines
      h = height ? height - 1 : -1
      w = width ? width - 1 : -1
      lines[scroll.y .. h].map { |line| line[scroll.x .. w] }
    end

    # ====================
    # To Text Methods
    # ====================

    def as_text
      lines.join "\n"
    end

    alias as_full_text as_text

    def as_displayed_text
      displayed_lines.join "\n"
    end

    def default_attributes
      {
        :lines => Lines.new([]),
        # :width => max_width,
        # :height => mac_height,
        :scroll => Scroll.new(0, 0)
      }
    end
  end

  Window::Lines = Array
  Window::Scroll = Struct.new :x, :y
end
