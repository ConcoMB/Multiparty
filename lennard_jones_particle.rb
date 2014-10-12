
class LennardJonesParticle

  attr_accessor :x, :y, :vx, :vy, :m, :fx, :fy

  RM = 1.0
  EPS = 1.0
  R = 5.0
  RMIN = 0
  V_D = 10.0
  HEIGHT = 200.0
  WIDTH = 400.0
  M = 100
  MAX_F = 100

  def initialize(x = nil, y = nil, vx = nil, vy = nil)
    if vx.nil? && vy.nil?
      self.vx = Random.rand((- V_D / 2)..(V_D / 2))
      self.vy = Random.rand((- V_D / 2)..(V_D / 2))
    else
      self.vx = vx
      self.vy = vy
    end
    if y.nil?
      self.y = Random.rand(0..HEIGHT) 
    else
      self.y = y
      if self.y >= HEIGHT
        self.y = HEIGHT
      elsif self.y <= 0
        self.y = 0
      end
    end
    if x.nil?
      self.x = Random.rand(0..(WIDTH / 2)) 
    else
      self.x = x
      if (self.x >= (WIDTH / 2) - 1 && self.x <= (WIDTH / 2) + 1 ) && (self.y < 90 || self.y > 110)
        self.x = WIDTH / 2  - 1
      end
      if self.x >= WIDTH
        self.x = WIDTH
      elsif self.x <= 0 
        self.x = 0
      end
    end
    self.m = M
    # self.f = 12 * EPS / RM * ((RM / r) ** 13 - (RM / r) ** 7)
    # self.a = self.f 
    # init_r
  end

  def cynematic
    m * (vx ** 2) * (vy ** 2) / 2 
  end

  def potential(particles)
    potential = 0
    particles.each do |p|
      next if self == p
      delta_x = (self.x - p.x)
      delta_y = (self.y - p.y)
      px = 0
      py = 0
      px = EPS * ((RM / delta_x) ** 12 - 2 * (RM / delta_x) ** 6) if delta_x.abs < R && delta_x != 0
      py = EPS * ((RM / delta_y) ** 12 - 2 * (RM / delta_y) ** 6) if delta_y.abs < R && delta_y != 0 
      if px > 0
        px = [px, MAX_F].min
      else 
        px = [px, - MAX_F].max
      end
      if py > 0
        py = [py, MAX_F].min
      else 
        py = [py, - MAX_F].max
      end
      potential += px + py
    end
    potential
  end

  def force(particles)
    self.fx = 0
    self.fy = 0
    particles.each do |p|
      next if self == p
      delta_x = (self.x - p.x)
      delta_y = (self.y - p.y)
      self.fx += 12 * EPS / RM * ((RM / delta_x) ** 13 - (RM / delta_x) ** 7) if delta_x.abs < R && delta_x.abs > RMIN
      self.fy += 12 * EPS / RM * ((RM / delta_y) ** 13 - (RM / delta_y) ** 7) if delta_y.abs < R && delta_y.abs > RMIN
      if fx > 0
        self.fx = [self.fx, MAX_F].min
      else 
        self.fx = [self.fx, - MAX_F].max
      end
      if fy > 0
        self.fy = [self.fy, MAX_F].min
      else 
        self.fy = [self.fy, - MAX_F].max
      end
      # puts "#{fx} #{fy}"
    end
  end

end