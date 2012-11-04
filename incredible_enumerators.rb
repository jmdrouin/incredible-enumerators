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
  def concat that
    Enumerator.new do |yielder|
      each {|x| yielder << x}
      that.each {|x| yielder << x}
    end
  end
  alias_method :+, :concat

  # Product of two enumerators: enumerates all the combinations of one
  # element of both enumerators
  # Example: (0..1).product(8..9).to_a == [[0,8],[0,9],[1,8],[1,9]]
  def product(that)
    Enumerator.new do |yielder|
      each do |x|
        that.each {|y| yielder << [x,y]}
      end
    end
  end

  # Product of two enumerators, flattening any enumerated element
  def flat_product(that)
    Enumerator.new do |yielder|
      each do |x|
        that.each {|y| yielder << [*x,*y]}
      end
    end
  end

  # Same as #product when an Enumerable is given,
  # same as #cycle when an Integer is given
  def * that
    case that
    when Enumerable then product(that)
    when Integer    then cycle(that)
    end
  end

  # Enumerates all repeated permutations (see Array#repeated_permutations)
  def repeated_permutation(n)
    case n
    when 0 then [[]].each
    when 1 then through{|x| [x] }
    else flat_product(repeated_permutation(n-1))
    end
  end
  alias_method :**, :repeated_permutation

  # Only enumerates element where the index fits the predicate
  def where_index(&predicate)
    Enumerator.new do |yielder|
      each.with_index do |x, i|
        yielder.yield(x) if predicate.call(i)
      end
    end
  end

  # Skips the n first elements of the enumeration
  def skip(n)
    where_index {|i| i >= n}
  end

  # Skips enumeration of nil elements (similar to Array#compact)
  def compact
    where{|x| !x.nil? }
  end

  # Instead of yielding enumerable elements (containers), enumerate
  # on them. Similar to Array#flatten.
  # Example: [1,[2,3]].each.flatten.max == 3
  def flatten(level=-1)
    case level
    when 0 then each
    else
      Enumerator.new do |yielder|
        each do |x|
          if x.is_a? Enumerable
            x.flatten(level-1).each do |nested_element|
              yielder << nested_element
            end
          else
            yielder << x
          end
        end
      end
    end
  end

  # Prevents enumerating the same element twice. Similar to
  # Array#uniq.
  def uniq
    Enumerator.new do |yielder|
      visited_elements = []
      each do |element|
        unless visited_elements.include? element
          visited_elements << element
          yielder << element
        end
      end
    end
  end

  # Merges the enumeration without repetitions. Similar to Array#&
  def & that
    (self + that).uniq
  end

  # Skips the elements of the right-hand enumerator. Like Array#-
  def - that
    where {|x| !that.include?(x) }
  end

  # All possible combinations of n distinct elements
  # from the enumerator. Similar to Array#combination.
  def combination(n)
    case n
    when 0 then [[]].each
    when 1 then through{|x| [x]}
    else
      Enumerator.new do |yielder|
        each.with_index do |element, index|
          skip(index+1).combination(n-1).each do |*permutations|
            yielder.yield(element, *permutations.flatten(1))
          end
        end
      end
    end
  end

end
