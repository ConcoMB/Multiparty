
class LennardJonesParticle

  attr_accessor :id, :x, :y, :vx, :vy, :m, :fx, :fy

  RM = 1.0
  EPS = 1.0
  R = 5.0
  RMIN = 0
  V_D = 10.0
  HEIGHT = 200.0
  WIDTH = 400.0
  M = 10 ** 1
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
      self.y = Random.rand(D2..(HEIGHT - D2)) 
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
      self.x = Random.rand(D2..((WIDTH / 2) - D2)) 
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
      delta_x = (self.x - p.x)
      delta_y = (self.y - p.y)
      self.fx += 12 * EPS / RM * ((RM / delta_x) ** 13 - (RM / delta_x) ** 7)
      self.fy += 12 * EPS / RM * ((RM / delta_y) ** 13 - (RM / delta_y) ** 7)
    end
    
    self.fx = MAX_F if fx > MAX_F
    self.fx = - MAX_F if fx < - MAX_F
    self.fy = MAX_F if fy > MAX_F
    self.fy = - MAX_F if fy < - MAX_F

    # puts "#{fx} #{fy}"
    [fx, fy]
  end

  def ax
    fx / m
  end

  def ay
    fy / m
  end

  def cynematic
    m * (vx ** 2) * (vy ** 2) / 2 
  end

  def potential(particles)
    potential = 0
    particles.each do |p|
      next if self.id == p.id
      delta_x = (self.x - p.x)
      delta_y = (self.y - p.y)
      px = 0
      py = 0
      px = EPS * ((RM / delta_x) ** 12 - 2 * (RM / delta_x) ** 6) if delta_x.abs < R && delta_x != 0
      py = EPS * ((RM / delta_y) ** 12 - 2 * (RM / delta_y) ** 6) if delta_y.abs < R && delta_y != 0 
      # if px > 0
      #   px = [px, MAX_F].min
      # else 
      #   px = [px, - MAX_F].max
      # end
      # if py > 0
      #   py = [py, MAX_F].min
      # else 
      #   py = [py, - MAX_F].max
      # end
      potential += px + py
    end
    potential
  end

  def distance(p)
    Math.sqrt((x - p.x) ** 2 + (y - p.y) ** 2)
  end

end