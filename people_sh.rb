#!/usr/bin/env ruby

require 'byebug'
require_relative 'people_particle'
require_relative 'opts'
require_relative 'parsing_utils'
require_relative 'people_dynamics'

def random_pos(id) 
  return [Random.rand(2.0..(W - 2).to_f), Random.rand(2.to_f..(H - 2).to_f)] if id <= N / 2
  [Random.rand((W.to_f + D + 2)..(D + W * 2 - 2).to_f), Random.rand(2.to_f..(H - 2).to_f)]
end

opts = parse_opts({})
N = opts[:n].to_i
W = opts[:w].to_i
D = opts[:d].to_i
H = opts[:h].to_i
GOAL_MARGIN = 20
id = 1
particles = []
if opts[:battle_p]
  BATTLE_P = opts[:battle_p].to_f 
else
  BATTLE_P = 0.5
end
(0..N).each do
  is_inserted = false
  while !is_inserted do
    x, y = random_pos(id) 
    color = id <= N / 2 ? 0 : 1
    p = PeopleParticle.new(id, color, x, y)
    unless particles.any? { |q| p.superposed? q }
      id += 1
      particles << p
      is_inserted = true
    end
  end
end
# (5..15).each do |i|
#   (5..15).each do |j|
#     particles << PeopleParticle.new(id, 0, i, j, false, 0, 0, vd = 2)
#     id += 1
#   end
# end
# (1..100).each do
#   is_inserted = false
#   while !is_inserted do
#     x, y = random_pos(id) 
#     color = 1
#     p = PeopleParticle.new(id, color, x, y)
#     unless particles.any? { |q| p.superposed? q }
#       id += 1
#       particles << p
#       is_inserted = true
#     end
#   end
# end

# (5..15).each do |i|
#   particles << PeopleParticle.new(id, 0, 6, i, false, 0, 0, vd = 2)
#   id += 1
# end
# (6..14).each do |i|
#   particles << PeopleParticle.new(id, 0, 7, i, false, 0, 0, vd = 2)
#   id += 1
# end
# (7..13).each do |i|
#   particles << PeopleParticle.new(id, 0, 8, i, false, 0, 0, vd = 2)
#   id += 1
# end
# (8..12).each do |i|
#   particles << PeopleParticle.new(id, 0, 9, i, false, 0, 0, vd = 2)
#   id += 1
# end
# (9..11).each do |i|
#   particles << PeopleParticle.new(id, 0, 10, i, false, 0, 0, vd = 2)
#   id += 1
# end
# (10..10).each do |i|
#   particles << PeopleParticle.new(id, 0, 11, i, false, 0, 0, vd = 2)
#   id += 1
# end
# n = particles.size
# puts n
# (1..N).each do
#   is_inserted = false
#   while !is_inserted do
#     x, y = random_pos(id) 
#     color = 1
#     p = PeopleParticle.new(id, color, x, y)
#     unless particles.any? { |q| p.superposed? q }
#       id += 1
#       particles << p
#       is_inserted = true
#     end
#   end
# end



delta_t = opts[:delta_t] ? opts[:delta_t].to_f : nil

#   def initialize(id, color, x, y, vx = 0, vy = 0)

# particles = [PeopleParticle.new(1, 0, 30, 15, -10, -10)]
# particles = [PeopleParticle.new(1, 0, 10, H/2), PeopleParticle.new(2, 1, 20, 0.2 + H/2)]
# particles = [PeopleParticle.new(1, 0, 10, 10), PeopleParticle.new(2, 0, 10, H - 10), PeopleParticle.new(3, 1, W*2+D - 10, H - 10), PeopleParticle.new(4, 1, W*2+D - 10, 10)]
# goals = (-H..(2 * H)).map { |i| PeopleParticle.new(0, 1, -GOAL_MARGIN, i) } +
#         (-H..(2 * H)).map { |i| PeopleParticle.new(0, 0, GOAL_MARGIN + W * 2 + D, i) }
goals = (0..H).step(0.1).map { |i| PeopleParticle.new(0, 1, 0, i) } +
        (0..H).step(0.1).map { |i| PeopleParticle.new(0, 0, W * 2 + D, i) }

calculate(particles, goals, delta_t, opts[:fight] == 'true', opts[:out_file])
