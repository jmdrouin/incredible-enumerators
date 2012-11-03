# (c) 2012 Jerome Morin-Drouin | jmdrouin@gmail.com

require "./incredible_enumerators.rb"

describe IncredibleEnumerator do
  it "can avoid some values using #where" do
    enum = (0...10).each.where(&:even?)
    enum.to_a.should == [0,2,4,6,8]
  end
end
