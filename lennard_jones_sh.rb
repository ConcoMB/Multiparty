#!/usr/bin/env ruby

require 'byebug'
require_relative 'lennard_jones_particle'
require_relative 'opts'
require_relative 'parsing_utils'
require_relative 'lennard_dynamics'

opts = parse_opts({})
particles = (1..opts[:p].to_i).map { LennardJonesParticle.new }
# particles = [ LennardJonesParticle.new(50, 0.5, 0, 0), LennardJonesParticle.new(0.5, 50, 0, 0) ]
calculate(particles, opts[:n].to_f, opts[:out_file])
