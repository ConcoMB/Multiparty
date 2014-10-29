class SiloParticle

  attr_accessor :id, :r, :x, :y, :vx, :vy, :fx, :fy, :m

  KN = 10 ** 3
  KT = 2 * KN
  M = 0.01
  G = - 10

  MAX_F = 5

  def initialize(id, r, x, y, vx = 0, vy = 0, wall = false)
    self.id = id
    self.r = r
    self.x = x
    self.y = y
    self.vx = vx
    self.vy = vy
    self.m = M
    # unless wall
      # d = r - r / 10
      # self.x = d if x < d
      # self.x = W - d if x > W - d
      # self.y = r if y < r && y >= 0 && (x - r < D_OFFSET || x + r > D + D_OFFSET)
      # self.y = L  if y > L
    # end
  end

  # Fn = −Kn ξ N
  # Ft = -Kt ξ [Rrel . t] t
  def force(particles)
    fx = 0.0
    fy = M * G
    if y <= 0 # || (y < r && y >= 0 && (x - r < D_OFFSET || x + r > D + D_OFFSET))
      self.fx = 0
      self.fy = 0
      return
    end
    particles.select { |p| distance(p) <= r * 2 && p.id != id && p.y > 0 }.each do |p|
      d = distance(p)
      # next if d < 0.1
      xi = r + p.r - d
      # xi = 0 if xi < 0 || xi > 1
      enx = (p.x - x) / d
      eny = (p.y - y) / d
      en = [enx, eny]
      et = [-eny, enx]
      rrel = [vx - p.vx, vy - p.vy]
      rrelt = rrel[0] * et[0] + rrel[1] * et[1]
      fn = - KN * xi
      ft = - KT * xi * rrelt
      fx += fn * enx + ft * (-eny)
      fy += fn * eny + ft * enx
    end

    if x <= r
      fx += - KN * (x - r)
    elsif x >= W - r
      fx += - KN * (x - (W - r))
    end
    if y <= r && (x - r < D_OFFSET || x + r > D + D_OFFSET)
      fy += - KN * (y - r)
    end
    self.fx = fx
    self.fy = fy
  end

  def ax
    fx / m
  end

  def ay
    fy / m
  end

  def v
    Math.sqrt(v_2)
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
