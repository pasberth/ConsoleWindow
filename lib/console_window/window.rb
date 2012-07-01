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
    attr_accessor :scroll

    def displayed_lines
      lines[scroll.y .. -1].map { |line| line[scroll.x .. -1] }
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
        :scroll => Scroll.new(0, 0)
      }
    end
  end

  Window::Lines = Array
  Window::Scroll = Struct.new :x, :y
end
