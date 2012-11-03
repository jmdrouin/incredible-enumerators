# (c) 2012 Jerome Morin-Drouin | jmdrouin@gmail.com

require "./incredible_enumerators.rb"

describe IncredibleEnumerator do
  it "is included in the Enumerator class" do
    Enumerator.included_modules.should include(IncredibleEnumerator)
  end
end
