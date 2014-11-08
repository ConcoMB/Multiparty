class PeopleParticle

  attr_accessor :id, :r, :x, :y, :vx, :vy, :fx, :fy, :m, :red, :blue, :dy, :dx, :color, :dead, :vd

  KN = 10 ** 5
  KT = 0 # KN / 10
  M = 80
  R = 0.25
  A = 2000
  B = 0.08
  TAU = 0.5
  VD = 2
  VD_DELTA = 1 

  def initialize(id, color, x, y, dead = false, vx = 0, vy = 0, vd = nil)
    self.id = id
    self.r = R
    self.x = x
    self.y = y
    self.vx = vx
    self.vy = vy
    self.m = M
    self.red = color
    self.blue = 1 - color
    self.color = color
    self.dx = red? ? -GOAL_MARGIN : W * 2 + D + GOAL_MARGIN
    self.dy = y
    unless vd 
      vd = Random.rand((VD - VD_DELTA)..(VD + VD_DELTA))
    end
    self.vd = vd
    self.dead = dead
    self.x = 0 if x < 0 
    self.x = W * 2 + D if x > W * 2 + D 
    self.y = 0 if y < 0 
    self.y = H if y > H 
  end

  def fight(particles)
    return if dead
    particles.select { |p| !p.dead && p.color != color && distance(p) < 2 * r + 0.1 }.each do |p|
      r = Random.rand(0.0..1.0)
      if (red? && r < BATTLE_P) || (blue? && r >= BATTLE_P) 
        self.dead = true
        return
      end
      p.dead = true
    end 
  end 

  def force(particles)
    self.fx = 0.0
    self.fy = 0.0
    # return if dead
    return if in_goal?
    granular_force(particles)
    driving_force
    social_force(particles)
  end

  # F = A * exp ** (ξ / B) * eij
  def social_force(particles)
    return if dead
    fx = 0.0
    fy = 0.0
    particles.select { |p| p.id != id && !p.dead }.each do |p|
      # d = distance(p)
      # xi = r + p.r - d
      # f = A * Math::E ** (xi / B)
      # delta_x = (x - p.x)
      # delta_y = (y - p.y)
      # angle = Math.atan2(delta_y, delta_x)
      # fx += f * Math.cos(angle)
      # fy += f * Math.sin(angle)
      d = distance(p)
      xi = r + p.r - d
      delta_x = -(p.x - x)
      delta_y = -(p.y - y)
      mod = Math.sqrt(delta_x ** 2 + delta_y ** 2)
      e_x = delta_x / mod
      e_y = delta_y / mod
      fx += A * Math::E ** (xi / B) * e_x
      fy += A * Math::E ** (xi / B) * e_y
    end
    self.fx += fx
    self.fy += fy
  end

  # F = M * (vdi * e - vi) / tau 
  def driving_force
    # f = m * (VD - vx.abs) / TAU
    # f *= -1 if (red? && f > 0) || (blue? && f < 0)
    # self.fx += f
    driving_v = vd
    driving_v = 0 if dead
    delta_x = (dx - x)
    delta_y = (dy - y)
    mod = Math.sqrt(delta_x ** 2 + delta_y ** 2)
    e_x = delta_x / mod
    e_y = delta_y / mod
    # angle = Math.atan2(delta_y, delta_x)
    fx = m * (driving_v * e_x - vx) / TAU
    fy = m * (driving_v * e_y - vy) / TAU
    # fx = f * Math.cos(angle).abs
    # fy = f * Math.sin(angle).abs
    # fx *= -1 if red?
    # fy *= -1 if y > H / 2
    self.fx += fx
    self.fy += fy
  end

  # Fn = −Kn ξ N
  # Ft = -Kt ξ [Rrel . t] t
  def granular_force(particles)
    fx = 0.0
    fy = 0.0
    particles.select { |p| p.id != id  && distance(p) <= 2 * r }.each do |p|
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
    if y <= r
      xi = (y - r)
      fy += - KN * xi
    end
    if y >= H - r
      xi = (y - (H - r))
      fy += - KN * xi
    end
    self.fx += fx
    self.fy += fy
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

  def cinetic
    m * v_2 / 2
  end

  def red?
    red == 1
  end

  def blue?
    !red?
  end

  def in_goal?
    return true if red? && x <= r
    return true if blue? && x >= W * 2 + D
    false
  end

end
