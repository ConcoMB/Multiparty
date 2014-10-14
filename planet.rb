class Planet

  COLLAPSE_DISTANCE = 1
  INIT_MIN_DISTANCE = 10
  INIT_MAX_DISTANCE = 100
  G = 6.693
  SUN_MASS = 2 * 10 ** 22

  attr_accessor :m, :x, :y, :vx, :vy, :r

  def initialize(m, x =  nil, y = nil, vx = nil, vy = nil, r = 0.1)
    self.m = m
    self.x = x
    self.y = y
    self.vx = vx
    self.vy = vy
    self.r = r
    if x.nil? && y.nil?
      rad = Random.rand(INIT_MIN_DISTANCE..INIT_MAX_DISTANCE)
      tita = Random.rand(0..(2 * Math::PI))
      self.x = rad * Math.cos(tita)
      self.y = rad * Math.sin(tita)
    end 
    # if vx.nil? && vy.nil?
    # end
  end

  def force(p)
    fx = G * m * p.m / ((x - p.x) ** 2)
    fy = G * m * p.m / ((y - p.y) ** 2) 
    [fx, fy]
  end

  def potential(p)
    px = - G * m * p.m / (x - p.x)
    py = - G * m * p.m / (y - p.y) 
    [px, py]
  end

  # attr_accessor :m, :r, :tita, :vr, :vtita

  # def initialize(m, r, t)
  #   self.m = m
  #   self.r = r
  #   self.tita = t
  # end

  # def force(p)
  #   G * m * p.m / (distance(p) ** 2) 
  # end

  # def distance(p)
  #   return Math.sqrt(r ** 2 + p.r ** 2 - 2 * r * p.r * Math.cos(tita - p.tita))
  # end

  # def potential(p)
  #   - G * m * p.m / distance(p) 
  # end

  # def x
  #   r * Math.cos(tita)
  # end

  # def y
  #   r * Math.sin(tita)
  # end

end