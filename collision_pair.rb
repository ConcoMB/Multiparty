class CollisionPair

  attr_accessor :a, :b, :delta_x, :delta_y, :delta_vx, :delta_vy, :sigma, :delta_r_delta_r, 
                :delta_v_delta_v, :delta_v_delta_r, :d, :j, :jx, :jy

  def initialize(a, b)
    @a = a
    @b = b
    return if wall?
    @delta_x = b.x - a.x
    @delta_y = b.y - a.y
    @delta_vx = b.v_x - a.v_x
    @delta_vy = b.v_y - a.v_y
    @sigma = b.r + a.r
    @delta_r_delta_r = @delta_x ** 2 + @delta_y ** 2
    @delta_v_delta_v = @delta_vx ** 2 + @delta_vy ** 2
    @delta_v_delta_r = @delta_vx * @delta_x + @delta_vy * @delta_y
    @d = @delta_v_delta_r ** 2 - @delta_v_delta_v * (@delta_r_delta_r - @sigma ** 2)
    @j = 2 * a.m * b.m * @delta_v_delta_r / (@sigma * (a.m + b.m))
    @jx = @j * @delta_x / @sigma
    @jy = @j * @delta_y / @sigma
  end

  def wall?
    @b == :vertical || @b == :horizontal
  end

end