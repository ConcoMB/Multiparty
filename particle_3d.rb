
class Particle3D

  attr_accessor :x, :y, :z, :v, :theta, :phi

  V = 0.03

  #  x = r sen theta cos phi 
  #  y = r sen theta sen phi
  #  z = r cos theta 

  def initialize(x, y, z, theta = nil, phi = nil)
    set_coords(x, y, z)
    self.v = V
    self.theta = theta
    self.phi = phi
    self.theta = Random.rand(0..(Math::PI)) unless self.theta
    self.phi = Random.rand(0..(2 * Math::PI)) unless self.phi
  end

  def set_coords(x, y, z)
    self.x = x % W
    self.y = y % H
    self.z = z % D
  end

  def move(t)
    set_coords(x + vx * t, y + vy * t, z + vz * t)
  end

  def distance(p)
    Math.sqrt((x - p.x) ** 2 + (y - p.y) ** 2 + (z - p.z) ** 2)
  end

  def alter(neighbors)
    self.theta = alter_field(neighbors, 'theta', Math::PI)
    self.phi = alter_field(neighbors, 'phi', 2 * Math::PI)
  end

  def alter_field(neighbors, field, max)
    sin_sum = neighbors.reduce(Math.sin(self.send(field))) { |a, e| a + Math.sin(e.send(field)) }
    sin_avg = sin_sum.to_f / (neighbors.size + 1)
    cos_sum = neighbors.reduce(Math.cos(self.send(field))) { |a, e| a + Math.cos(e.send(field)) }
    cos_avg = cos_sum.to_f / (neighbors.size + 1)
    noise = Random.rand((-ETA / 2)..(ETA / 2))
    avg = Math.atan(sin_avg / cos_avg)
    (avg + noise) % max
  end

  def vx 
    v * Math.sin(theta) * Math.cos(phi)
  end

  def vy
    v * Math.sin(theta) * Math.sin(phi)
  end

  def vz
    v * Math.cos(theta)
  end

  def v_mod
    Math.sqrt(vx ** 2 + vy ** 2 + vz ** 2)
  end

  def red
    ((vx / V) + 0.5) / 1.5
  end

  def green
    ((vy / V) + 0.5) / 1.5
  end

  def blue
    ((vz / V) + 0.5) / 1.5
  end

end