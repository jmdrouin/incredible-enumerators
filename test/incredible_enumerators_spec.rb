# (c) 2012 Jerome Morin-Drouin | jmdrouin@gmail.com

require "./lib/incredible_enumerators.rb"

describe "IncredibleEnumerator" do
  describe "#where" do
    it "filters the enumeration following the predicate" do
      enum = (0...10).each.where(&:even?)
      enum.to_a.should == [0,2,4,6,8]
    end

    it "runs the filter only when needed" do
      has_been_called = false

      enum = (0...10).each.where {has_been_called = true}
      has_been_called.should == false

      enum.to_a
      has_been_called.should == true
    end
  end

  describe "#with" do
    it "adds another object to the yielded ones" do
      enum = (0..4).each.with{|n| n % 3}
      enum.to_a.should == [[0,0],[1,1],[2,2],[3,0],[4,1]]
    end
  end

  describe "#through" do
    it "modifies each element of the enumeration using the filter" do
      has_been_called = false

      enum = (0...5).each.through do |x|
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
      enum = (0..2).each.concat ["a", "b"]
      enum.to_a.should == [0,1,2,"a","b"]
    end

    it "also works with +" do
      enum = (0..2).each + ["a", "b"].each
      enum.to_a.should == [0,1,2,"a","b"]
    end
  end

  describe "injector" do
    it "prepares an inject-like enumeration" do
      enum = (0..5).each.injector(0)
      enum.each{|memo, x| memo + x}.should == 1+2+3+4+5
    end

    it "has nil as default value" do
      enum = [1,2].each.injector
      enum.each{|memo,x| [memo] + [x]}.should == [[nil,1],2]
    end
  end

  describe "product" do
    it "will iterate over all combinations" do
      enum = (0..1).each.product([:a, :b])
      enum.to_a.should == [[0,:a], [0,:b], [1,:a], [1,:b]]
    end

    it "works with the * operator" do
      enum = (0..1).each * [:a, :b].each
      enum.to_a.should == [[0,:a], [0,:b], [1,:a], [1,:b]]
    end

    it "can handle enumerators over Arrays" do
      enum = [[1,2],[1,3]].each.product([:a, :b].each)
      enum.first.should == [[1,2],:a]
    end
  end

  describe "flat_product" do
    it "behaves like product, but flattens the elements" do
      enum = [[1,2]].each.flat_product([:a,:b])
      enum.to_a.should == [[1,2,:a], [1,2,:b]]
    end
  end

  describe "enumerator * n" do
    it "should enumerate n times" do
      enum = (0..1).each * 2
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
      enum = (0..1).each**3
      enum.to_a.should == [0,1].repeated_permutation(3).to_a
    end
  end

  describe "skip" do
    it "should skip the n first elements of the enumeration" do
      enum = (10..15).each.skip(3)
      enum.to_a.should == [13,14,15]
    end

    it "iterates immediatly if a block is given" do
      enum = (0..5).each.skip(3)
      enum.inject(&:+).should == 3+4+5
    end
  end

  describe "where_index" do
    it "should only iterate on indices that fulfill the predicate" do
      enum = [:zero, :one, :two, :three, :four].each.where_index(&:even?)
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
      enum = (3..5).each & (1..7).each
      enum.to_a.should == [3,4,5,1,2,6,7]
    end
  end

  describe "#-" do
    it "should not enumerate elements of the second enumerator" do
      enum = (1..9).each - (5..8).each
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

    it "does not keep structure if the level is 0" do
      tree = [ nil, [nil, [nil] ] ]
      tree.structural_map(0,&:nil?).should == [true,false]
    end

    it "keeps the structure up to the given level" do
      tree = [ nil, [nil, [nil, [nil] ] ] ]
      tree.structural_map(2,&:nil?).should == [true,[true,[true,false]]]
    end
  end

  describe "#zigzag" do
    it "iterates by alternance over the enumerables" do
      enum = [1,2,3].each.zigzag([:a,:b,:c].each)
      enum.to_a.should == [1,:a,2,:b,3,:c]
    end

    it "works with different sizes" do
      enum = [1,2,3,4].each.zigzag([:a,:b].each)
      enum.to_a.should == [1,:a,2,:b,3,4]

      enum = [1,2].each.zigzag([:a,:b,:c,:d].each)
      enum.to_a.should == [1,:a,2,:b,:c,:d]
    end

    it "can handle more than 2 enumerators" do
      enum = [1,2,3,4].each.zigzag([1,2,3].each, [1,2].each)
      enum.to_a.should == [1,1,1,2,2,2,3,3,4]
    end


  end
end
