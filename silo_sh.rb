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

opts = parse_opts({})
L = opts[:l].to_i.abs
W = opts[:w].to_i.abs
D = opts[:d].to_i.abs
D_OFFSET = opts[:d_offset].to_i.abs
# H = opts[:h].to_i
raise new Exception 'pecheaste los parametros' if L <= W || L <= D || W <= D || D + D_OFFSET > W #|| H > L
if D > 0
  R = D.to_f / 10
else
  R = 1
end
# initialize(id, r, x, y, vx, vy, ax, ay)
walls = (0..L).step(0.5).map { |i| SiloParticle.new(-1, R, 0 - R, i, 0, 0, true) } +
        (0..L).step(0.5).map { |i| SiloParticle.new(-1, R, W + R, i, 0, 0, true) } +
        (0..D_OFFSET).step(0.5).map { |i| SiloParticle.new(-1, R, i, 0, 0, 0, true) } +
        ((D_OFFSET + D)..W).step(0.5).map { |i| SiloParticle.new(-1, R, i, 0, 0, 0, true) }

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
