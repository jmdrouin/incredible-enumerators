# (c) 2012 Jerome Morin-Drouin | jmdrouin@gmail.com

module LazyEnumerator

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

  # Will add an object to the yielded ones, obtained using the
  # given proc. Example: [1,2].each.with(&:to_s).to_a == [[1,"1"],[2,"2"]]
  def with(&additional_object)
    Enumerator.new do |yielder|
      each do |x|
        yielder.yield(x,additional_object.call(x))
      end
    end
  end

  # Returns an enumerator whose #each method acts
  # like a normal inject/reduce
  def injector(memo=nil)
    Enumerator.new do |yielder|
      each do |x|
        memo = yielder.yield(memo, x)
      end
      memo
    end
  end
  alias_method :reducer, :injector

  # Only enumerates element where the index fits the predicate
  def where_index(&predicate)
    Enumerator.new do |yielder|
      each.with_index do |x, i|
        yielder.yield(x) if predicate.call(i)
      end
    end
  end

  # Skips the n first elements of the enumeration
  def skip(n, &block)
    where_index{|i| i >= n}.each(&block)
  end

  # Iterates over self and that by alternance. When any of the
  # enumerators is exhausted, the iteration continues for the
  # remaining one.
  def zigzag(that)
    Enumerator.new do |yielder|
      enumerators = [each, that]
      until enumerators.empty?
        enumerators.each do |enum|
          begin
            yielder << enum.next
          rescue StopIteration
            enumerators.delete(enum)
          end
        end
      end
    end
  end
end

module ArrayLikeEnumerator

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
  def repeated_permutation(n, &block)
    enum = case n
    when 0 then [[]].each
    when 1 then each.through{|x| [x] }
    else flat_product(repeated_permutation(n-1))
    end

    block ? enum.each(&block) : enum
  end
  alias_method :**, :repeated_permutation

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
    each.where {|x| !that.include?(x) }
  end

  # All possible combinations of n distinct elements
  # from the enumerator. Similar to Array#combination.
  def combination(n, &block)
    enum = case n
    when 0 then [[]].each
    when 1 then through{|x| [x]}
    else
      Enumerator.new do |yielder|
        each.with_index do |element, index|
          skip(index+1).combination(n-1).each do |*tail|
            yielder.yield(element, *tail.flatten(1))
          end
        end
      end
    end

    block ? enum.each(&block) : enum
  end

  # All possible permutations of n distinct elements
  # from the enumerator. Similar to Array#permutation.
  def permutation(n, &block)
    enum = case n
    when 0 then [[]].each
    when 1 then through{|x| [x]}
    else
      Enumerator.new do |yielder|
        each.with_index do |element, index|
          where_index{|i| i!=index}.permutation(n-1).each do |*tail|
            yielder.yield(element, *tail.flatten(1))
          end
        end
      end
    end

    block ? enum.each(&block) : enum
  end

  # All possible combinations of n elements with repetitions
  # from the enumerator. Similar to Array#repeated_combination.
  def repeated_combination(n, &block)
    enum = case n
    when 0 then [[]].each
    when 1 then through{|x| [x]}
    else
      Enumerator.new do |yielder|
        each.with_index do |element, index|
          skip(index).repeated_combination(n-1).each do |*tail|
            yielder.yield(element, *tail.flatten(1))
          end
        end
      end
    end

    block ? enum.each(&block) : enum
  end
end

class Enumerator
  include LazyEnumerator
  include ArrayLikeEnumerator
end

module Enumerable
  # Acts like collect or map, but keeps the internal structure.
  # Example: [1,[2,3]].structural_map{|x|x+1} == [2,[3,4]]
  def structural_map(level=-1, &block)
    collect do |x|
      if level==0 || !(Enumerable===x)
        block.call(x)
      else
        x.structural_map(level-1, &block)
      end
    end
  end
end
