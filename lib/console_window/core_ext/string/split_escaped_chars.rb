class String

  def each_escaped_char &block
    return Enumerator.new(self, :each_escaped_char) unless block_given?

    self.split(/(?=\e)/).each do |a|
      if a =~ /^\e\[\d*(?<COL>;\d+\g<COL>?)?m/
        e = $~[0]
        a.sub!(e, "")
        yield e.clone
        a.each_char &block
      else
        a.each_char &block
      end
    end

    self
  end

  def split_escaped_chars
    each_escaped_char.to_a
  end
end
