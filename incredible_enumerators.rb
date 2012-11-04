# (c) 2012 Jerome Morin-Drouin | jmdrouin@gmail.com

module Enumerable

  # Lazy filter. Returns an enumerator, similar to self, but
  # that will only enumerate the values fulfilling the given
  # predicate.
  # Example: (1..4).each.where(&:odd?).to_a == [1,3]
  def where(&predicate)
    Enumerator.new do |yielder|
      each do |x|
        yielder.yield(x) if predicate.call(x)
      end
    end
  end

  # Lazy enumerator modifier. Returns an enumerator, similar to self,
  # but that will enumerate values modified  by the given block.
  # Example: (1..4).each.through{|x|x+1}.to_a == [2,3,4,5]
  def through(&filter)
    Enumerator.new do |yielder|
      each do |x|
        yielder.yield(filter.call(x))
      end
    end
  end

  # Return an enumerator, which is just the sequence of two enumerators
  def + that
    Enumerator.new do |yielder|
      each {|x| yielder << x}
      that.each {|x| yielder << x}
    end
  end

  # Product of two enumerators: enumerates all the combinations of one
  # element of both enumerators
  # Example: ( (0..1) * (8..9) ).to_a == [[0,8],[0,9],[1,8],[1,9]]
  def * that
    Enumerator.new do |yielder|
      each do |x|
        that.each {|y| yielder << [x,y]}
      end
    end
  end

end
