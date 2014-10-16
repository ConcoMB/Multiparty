
class LennardJonesParticle

  attr_accessor :id, :x, :y, :vx, :vy, :m, :fx, :fy

  RM = 1.0
  EPS = 2.0
  R = 5.0
  RMIN = 0
  V_D = 10.0
  HEIGHT = 200.0
  WIDTH = 400.0
  M = 0.1
  MAX_F = 10 ** 5
  D = 0.05
  D2 = D * 2

  def initialize(id, x = nil, y = nil, vx = nil, vy = nil, wall = false)
    self.id = id
    if wall
      self.x = x
      self.y = y
      return
    end
    if vx.nil? && vy.nil?
      self.vx = Random.rand((- V_D / 2)..(V_D / 2))
      self.vy = Random.rand((- V_D / 2)..(V_D / 2))
    else
      self.vx = vx
      self.vy = vy
    end
    if y.nil?
      self.y = Random.rand(2..198) 
    else
      self.y = y
      if self.y > HEIGHT - D
        self.y = HEIGHT - D
        self.vy *= -1 if self.vy > 0
      elsif self.y < 0 + D
        self.y = 0 + D
        self.vy *= -1 if self.vy < 0
      end
    end
    if x.nil?
      self.x = Random.rand(2..198) 
    else
      self.x = x
      if self.x > WIDTH - D
        self.x = WIDTH - D
        self.vx *= -1 if self.vx > 0
      elsif self.x < D 
        self.x = 0 + D
        self.vx *= -1 if self.vx < 0
      elsif (y < 90 || y > 110) && x > WIDTH / 2 - D && x < WIDTH / 2 + D
        self.vx *= -1
      end
    end
    self.m = M
    # self.f = 12 * EPS / RM * ((RM / r) ** 13 - (RM / r) ** 7)
    # self.a = self.f 
    # init_r
  end

  def force(particles)
    self.fx = 0
    self.fy = 0
    
    particles.select{ |p| distance(p) < R }.each do |p|
      next if self.id == p.id
      d = distance(p)
      delta_x = x - p.x
      delta_y = y - p.y
      f = 12 * EPS / RM * ((RM / d) ** 13 - (RM / d) ** 7)
      angle = Math.atan2(delta_y, delta_x)
      self.fx += f * Math.cos(angle)
      self.fy += f * Math.sin(angle)
    end
    
    # self.fx = MAX_F if fx > MAX_F
    # self.fx = - MAX_F if fx < - MAX_F
    # self.fy = MAX_F if fy > MAX_F
    # self.fy = - MAX_F if fy < - MAX_F

    # # puts "#{fx} #{fy}"
    # [fx, fy]
  end

  def ax
    fx / m
  end

  def ay
    fy / m
  end

  def cynematic
    m * ((vx ** 2) + (vy ** 2)) / 2 
  end

  def potential(particles)
    potential = 0
    particles.each do |p|
      next if self.id == p.id
      d = distance(p)
      potential += EPS * ((RM / d) ** 12 - 2 * (RM / d) ** 6)
    end
    potential
  end

  def distance(p)
    Math.sqrt((x - p.x) ** 2 + (y - p.y) ** 2)
  end

end