# (c) 2012 Jerome Morin-Drouin | jmdrouin@gmail.com

module IncredibleEnumerator

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
end

class Enumerator
  include IncredibleEnumerator
end
