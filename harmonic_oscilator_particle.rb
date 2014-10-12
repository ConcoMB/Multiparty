class HarmonicOscilatorParticle

  attr_accessor :r, :v, :f, :m, :a, :r1, :r2, :r3, :r4, :r5

  M = 70.0
  K = 10000.0
  GAMMA = 100.0

  R_D = 1
  V_D = - GAMMA / M / 2

  def initialize(r = R_D, v = V_D)
    @r = r
    @v = v
    @m = M
    @f = - (K * r + GAMMA * v)
    @a = @f / @m
    init_r
  end

  def init_r
    @r1 = @v
    @r2 = @a
    @r3 = (- K * @r1 - GAMMA * @r2) / @m
    @r4 = (- K * @r2 - GAMMA * @r3) / @m
    @r5 = (- K * @r3 - GAMMA * @r4) / @m
  end

  def exact_r(t)
    Math::E ** (- (GAMMA / (2 * @m) * t)) * Math.cos(Math.sqrt(K / @m - GAMMA ** 2 / (4 * @m ** 2)) * t)
  end

end