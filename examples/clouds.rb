# (c) 2012 Jerome Morin-Drouin | jmdrouin@gmail.com

require 'incredible_enumerators'

# Suppose we have an cloud of points in a 2D space:
cloud = []

# Enumerable#through can give us an enumerator on their
# polar coordinates:
polar = cloud.through do |x,y|
  radius = Math::sqrt(x**2 + y**2)
  angle  = x==0 ? 0 : Math::atan(y/x)
  [radius, angle]
end

# We use Enumerable#where to prepare an enumerator on
# all the points within the (0,100) open disk:
disk = cloud.where {|x,y| x**2 + y**2 < 100**2}

# Let's add some points in the cloud, and see the result:
cloud << [0,50] << [10,10] <<[1,1]

puts "Points within the (0,100) disk: #{disk.to_a}"
# >>

puts "Points in polar coordinates: " +
     polar.collect {|r,a| [r.round,a.round]}.inspect
# >>
