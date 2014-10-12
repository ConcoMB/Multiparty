#!/usr/bin/env ruby

require 'byebug'
require_relative 'lennard_jones_particle'
require_relative 'opts'
require_relative 'parsing_utils'
require_relative 'lennard_dynamics'

opts = parse_opts({})
particles = (1..opts[:p].to_i).map { LennardJonesParticle.new }
# particles = [ LennardJonesParticle.new(10, 10), LennardJonesParticle.new(14, 11), LennardJonesParticle.new(9, 9), LennardJonesParticle.new(100, 11) ]
calculate(particles, opts[:n].to_f, opts[:out_file])
