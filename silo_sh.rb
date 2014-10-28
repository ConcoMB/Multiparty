#!/usr/bin/env ruby

require 'byebug'
require_relative 'silo_particle'
require_relative 'opts'
require_relative 'parsing_utils'
require_relative 'silo_dynamics'

def random_x
  Random.rand((2 * R)..(W - 2 * R))
end

def random_y
  Random.rand((2 * R)..(L - 2 * R))
end

# def valid_xy?(x, y)
  # return true if y > H || (x > D_OFFSET && x < D + D_OFFSET)
  # return y > f1(x) + 2 * R if x < D_OFFSET
  # return y > f2(x) + 2 * R if x > D_OFFSET
  # false
# end

# (0, H) to (d_offset, 0)
# x / d_offset = (y - H) / - H
# y = - (x * H) / d_offset + H
# def f1(x)
#   - (x * H) / D_OFFSET + H 
# end


# (D+d_offset, 0) to (W, H)
# (x - D - d_offset) / (W - D - d_offset) = y / H
# y = - H * (x - D - d_offset) / (W - D - d_offset)
# def f2(x)
#   H * (x - D - D_OFFSET) / (W - D - D_OFFSET)
# end

opts = parse_opts({})
L = opts[:l].to_i.abs
W = opts[:w].to_i.abs
D = opts[:d].to_i.abs
D_OFFSET = opts[:d_offset].to_i.abs
# H = opts[:h].to_i
raise new Exception 'pecheaste los parametros' if L <= W || L <= D || W <= D || D + D_OFFSET > W #|| H > L
R = D.to_f / 10

# initialize(id, r, x, y, vx, vy, ax, ay)
walls = (0..L).step(0.5).map { |i| SiloParticle.new(-1, R, 0, i, 0, 0, true) } +
        (0..L).step(0.5).map { |i| SiloParticle.new(-1, R, W, i, 0, 0, true) } +
        (0..D_OFFSET).step(0.5).map { |i| SiloParticle.new(-1, R, i, 0, 0, 0, true) } +
        ((D_OFFSET + D)..W).step(0.5).map { |i| SiloParticle.new(-1, R, i, 0, 0, 0, true) }
# walls = (H..L).step(0.5).map { |i| SiloParticle.new(-1, R, 0, i) } +
#         (H..L).step(0.5).map { |i| SiloParticle.new(-1, R, W, i) } +
#         [SiloParticle.new(-1, 0, D_OFFSET, 0, 0, 0), SiloParticle.new(-1, R, D_OFFSET + D, 0)]
# if D_OFFSET > 0
#   walls += (0..D_OFFSET).step(0.5).map { |i| SiloParticle.new(-1, R, i, f1(i)) }
# else
#   walls += (0..H).step(0.5).map { |i| SiloParticle.new(-1, R, 0, i) }
# end
# if D + D_OFFSET < W
#   walls += ((D_OFFSET + D)..W).step(0.5).map { |i| SiloParticle.new(-1, R, i, f2(i)) }
# else
#   walls += (0..H).step(0.5).map { |i| SiloParticle.new(-1, R, W, i) }
# end

id = 1
particles = []
(0..opts[:max].to_i).each do
  x = random_x
  y = random_y
  # next unless valid_xy?(x, y) 
  p = SiloParticle.new(id, R, x, y)
  unless particles.any? { |q| p.superposed? q }
    id += 1
    particles << p
  end
end

# particles = [SiloParticle.new(1, R, 10, 2), SiloParticle.new(2, R, 9, 4)]
# particles = [SiloParticle.new(1, R, 2, 5), SiloParticle.new(2, R, 2, 2)]
# particles = [SiloParticle.new(1, R, 9, 15, -1)]


delta_t = opts[:delta_t] ? opts[:delta_t].to_f : nil

# walls = []
# particles = [SiloParticle.new(-1, 1, 0, 0), SiloParticle.new(1, 1, 1, 1)]

calculate(particles, walls, delta_t, L, W, opts[:out_file])
