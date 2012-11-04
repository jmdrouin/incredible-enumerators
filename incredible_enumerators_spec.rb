# (c) 2012 Jerome Morin-Drouin | jmdrouin@gmail.com

require "./incredible_enumerators.rb"

describe "IncredibleEnumerator" do
  describe "#where" do
    it "filters the enumeration following the predicate" do
      enum = (0...10).where(&:even?)
      enum.to_a.should == [0,2,4,6,8]
    end

    it "runs the filter only when needed" do
      has_been_called = false

      enum = (0...10).where {has_been_called = true}
      has_been_called.should == false

      enum.to_a
      has_been_called.should == true
    end
  end

  describe "#through" do
    it "modifies each element of the enumeration using the filter" do
      has_been_called = false

      enum = (0...5).through do |x|
        has_been_called = true
        x+1
      end

      has_been_called.should == false
      enum.to_a.should == [1,2,3,4,5]
      has_been_called.should == true
    end
  end

  describe "#concat" do
    it "will iterate on all the concatenated enumerators" do
      enum = (0..2).concat ["a", "b"]
      enum.to_a.should == [0,1,2,"a","b"]
    end

    it "also works with +" do
      enum = (0..2) + ["a", "b"]
      enum.to_a.should == [0,1,2,"a","b"]
    end
  end

  describe "product" do
    it "will iterate over all combinations" do
      enum = (0..1).product([:a, :b])
      enum.to_a.should == [[0,:a], [0,:b], [1,:a], [1,:b]]
    end

    it "works with the * operator" do
      enum = (0..1) * [:a, :b]
      enum.to_a.should == [[0,:a], [0,:b], [1,:a], [1,:b]]
    end

    it "can handle enumerators over Arrays" do
      enum = [[1,2],[1,3]].product([:a, :b])
      enum.first.should == [[1,2],:a]
    end
  end

  describe "flat_product" do
    it "behaves like product, but flattens the elements" do
      enum = [[1,2]].flat_product([:a,:b])
      enum.to_a.should == [[1,2,:a], [1,2,:b]]
    end
  end

  describe "enumerator * n" do
    it "should enumerate n times" do
      enum = (0..1) * 2
      enum.to_a.should == [0,1,0,1]
    end
  end

  describe "repeated_permutation" do
    it "should enumerate only an empty array, for n=0" do
      enum = (0..2).each.repeated_permutation(0)
      enum.to_a.should == [[]]
    end

    it "should enumerate arrays of size 1, for n=1" do
      enum = (0..2).each.repeated_permutation(1)
      enum.to_a.should == [[0],[1],[2]]
    end

    it "should enumerate all the repeated permutations, for n > 1" do
      enum = (0..2).each.repeated_permutation(2)
      enum.to_a.should == [0,1,2].repeated_permutation(2).to_a
    end

    it "works with the ** operator" do
      enum = (0..1)**3
      enum.to_a.should == [0,1].repeated_permutation(3).to_a
    end
  end

  describe "skip" do
    it "should skip the n first elements of the enumeration" do
      enum = (10..15).skip(3)
      enum.to_a.should == [13,14,15]
    end
  end

  describe "where_index" do
    it "should only iterate on indices that fulfill the predicate" do
      enum = [:zero, :one, :two, :three, :four].where_index(&:even?)
      enum.to_a.should == [:zero, :two, :four]
    end
  end

  describe "compact" do
    it "iterates only on non-nil objects" do
      enum = [1, nil, 1, nil].each.compact
      enum.to_a.should == [1,1]
    end
  end

  describe "flatten" do
    it "iterates also on enumerables of the given level" do
      array = [[1,2],3,[[4]]]
      (0..3).each do |level|
        array.each.flatten(level).to_a.should == array.flatten(level)
      end
    end

    it "flattens without end if no level is given" do
      array = [1,[2,[3,[4]]]]
      array.each.flatten.to_a.should == array.flatten
    end
  end

  describe "uniq" do
    it "should never enumerate twice the same element" do
      enum = [0,0,1,0,0,1,2].each.uniq
      enum.to_a.should == [0,1,2]
    end
  end

  describe "#&" do
    it "should merge the enumeration, without duplicates" do
      enum = (3..5) & (1..7)
      enum.to_a.should == [3,4,5,1,2,6,7]
    end
  end

  describe "#-" do
    it "should not enumerate elements of the second enumerator" do
      enum = (1..9) - (5..8)
      enum.to_a.should == [1,2,3,4,9]
    end
  end

  describe "#combination" do
    it "behaves like Array#combination" do
      array = [1,2,3,4]
      (0..5).each do |n|
        enum = array.each.combination(n)
        enum.to_a.should == array.combination(n).to_a
      end
    end
  end

  describe "#permutation" do
    it "behaves like Array#permutation" do
      array = [1,2,3,4]
      (0..5).each do |n|
        enum = array.each.permutation(n)
        enum.to_a.should == array.permutation(n).to_a
      end
    end
  end

  describe "#repeated_combination" do
    it "behaves like Array#repeated_combination" do
      array = [1,2,3,4]
      (0..5).each do |n|
        enum = array.each.repeated_combination(n)
        enum.to_a.should == array.repeated_combination(n).to_a
      end
    end
  end

  describe "#structural_map" do
    it "leaves the structure of arrays intact" do
      tree = [1,2,[3,4],5]
      tree.structural_map(&:even?).should == [false,true,[false,true],false]
    end

    it "works with non-array enumerables" do
      tree = [1,2,3..5]
      tree.structural_map(&:even?).should == [false,true,[false,true,false]]
    end

    it "goes as deep as wanted, by default" do
      tree = [1,[2,[3]]]
      tree.structural_map{|x|x*10}.should == [10,[20,[30]]]
    end
  end
end
