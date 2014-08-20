class Particle

  attr_accessor :x, :y, :r, :color, :id

  def initialize(id, x, y)
    @id = id
    @x = x
    @y = y
  end

  def to_s
    "#{id}: (#{@x}, #{@y})"
  end

end