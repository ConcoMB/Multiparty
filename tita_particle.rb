class TitaParticle

  attr_accessor :x, :y, :r, :color, :id, :v, :tita

  def initialize(id, x, y)
    @id = id
    @x = x
    @y = y
  end

  def move(t, max)
    @x = (@x + (t * v_x)) % max
    @y = (@y + (t * v_y)) % max
    self
  end

  def v_x
    Math.sin(@tita) * @v
  end

  def v_y
    Math.cos(@tita) * @v
  end

  def to_s
    "#{@id}: (#{@x}, #{@y})"
  end

end