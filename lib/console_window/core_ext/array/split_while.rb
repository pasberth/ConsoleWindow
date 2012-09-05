class Array

  def split_while
    index = inject(0) do |index, item|
      yield(item) ? index + 1 : break index
    end

    [self[0, index], self[index..-1]]
  end
end
