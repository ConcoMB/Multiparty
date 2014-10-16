#!/usr/bin/env ruby

require 'byebug'
require_relative 'lennard_jones_particle'
require_relative 'opts'
require_relative 'parsing_utils'
require_relative 'lennard_dynamics'

opts = parse_opts({})
particles = []
(1..opts[:p].to_i).each do |i|
  p = LennardJonesParticle.new(i)
  while particles.any? { |q| p.distance(q) <= 1 }
    p = LennardJonesParticle.new(i)
  end
  particles << p
end
# particles = [ LennardJonesParticle.new(1, 205, 50, -5, 0) ]
calculate(particles, opts[:n].to_f, opts[:delta_t].to_f, opts[:out_file])
