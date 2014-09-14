class TwoDParticle

  attr_accessor :x, :y, :r, :id, :v_x, :v_y

  def initialize(id, x, y, r, v_x = 0, v_y = 0)
    @id = id
    @x = x
    @y = y
    @r = r
    @v_x = v_x
    @v_y = v_y
  end

  def move(t)
    @x = @x + (t * v_x)
    @y = @y + (t * v_y)
    self
  end

  def to_s
    "#{@id}: (#{@x}, #{@y})"
  end  

end