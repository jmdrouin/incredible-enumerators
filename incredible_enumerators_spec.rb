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

  describe "+" do
    it "will iterate on all the added enumerators" do
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
  end

  describe "enumerator * n" do
    it "should enumerate n times" do
      enum = (0..1) * 2
      enum.to_a.should == [0,1,0,1]
    end
  end

  describe "repeated_permutation" do
    it "should enumerate only an empty array, for n=0" do
      enum = (0..2).each.repeated_permutations(0)
      enum.to_a.should == [[]]
    end

    it "should enumerate arrays of size 1, for n=1" do
      enum = (0..2).each.repeated_permutations(1)
      enum.to_a.should == [[0],[1],[2]]
    end

    it "should enumerate all the repeated permutations, for n > 1" do
      enum = (0..2).each.repeated_permutations(2)
      expectation = (0..2).to_a.repeated_permutations(2).to_a
      (enum.to_a - expectation).size.should == 0
    end
  end
end
