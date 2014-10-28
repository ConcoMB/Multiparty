class SiloParticle

  attr_accessor :id, :r, :x, :y, :vx, :vy, :fx, :fy, :m

  KN = 10 ** 3
  KT = 2 * KN
  M = 0.01
  G = - 5

  MAX_F = 1

  def initialize(id, r, x, y, vx = 0, vy = 0, wall = false)
    self.id = id
    self.r = r
    self.x = x
    self.y = y
    self.vx = vx
    self.vy = vy
    self.m = M
    unless wall
      self.x = r if x < r
      self.x = W - r if x > W - r
      self.y = r if y < r if (x - r < D_OFFSET || x + r > D + D_OFFSET)
      self.y = L - r if y > L - r
    end
  end

  # Fn = −Kn ξ N
  # Ft = -Kt ξ [Rrel . t] t
  def force(particles)
    fx = 0
    fy = M * G
    particles.select { |p| distance(p) <= r * 2.5 && p.id != id }.each do |p|
      xi = r + p.r - distance(p)
      xi = 0 if xi < 0 || xi > 1
      enx = (p.x - x) / distance(p)
      eny = (p.y - y) / distance(p)
      en = [enx, eny]
      et = [-eny, enx]
      rrel = [vx - p.vx, vy - p.vy]
      rrelt = rrel[0] * et[0] + rrel[1] * et[1]
      fn = - KN * xi 
      ft = - KT * xi * rrelt
      fx += fn * enx + ft * (-eny)
      fy += fn * eny + ft * enx
    end

    # paredes
    # xi = r - x
    # # xi = 0 if xi < 0 || xi > 1
    # fx += - KN * xi
    # xi = r - (W - x)
    # # xi = 0 if xi < 0 || xi > 1
    # fx += - KN * xi
    # if x - r < D_OFFSET || x + r > D + D_OFFSET
    #   xi = r - y
    #   # xi = 0 if xi < 0 || xi > 1
    #   fy += - KN * xi
    # end
    if x <= r
      fx += - KN * (x - r) 
    elsif x >= W - r
      fx += - KN * (x - W - r)  
    end
    if y <= r && (x - r < D_OFFSET || x + r > D + D_OFFSET)
      fy += - KN * (y - r)
    end
    self.fx = fx
    self.fy = fy

    puts "#{fx}, #{fy}"
    fx = 0 if fx == Float::NAN
    fy = 0 if fy == Float::NAN
    if fx < 0
      self.fx = [fx, MAX_F].min 
    else
      self.fx = [fx, -MAX_F].max 
    end
    if fy < 0
      self.fy = [fy, MAX_F].min
    else
      self.fy = [fy, -MAX_F].max 
    end
  end

  def ax
    fx / m
  end

  def ay
    fy / m
  end

  def v
    Math.sqrt(vx ** 2 + vy ** 2)
  end

  def v_2
    (vx ** 2 + vy ** 2)
  end

  def superposed?(q)
    distance(q) < (r + q.r)
  end

  def distance(p)
    Math.sqrt((x - p.x) ** 2 + (y - p.y) ** 2)
  end

end