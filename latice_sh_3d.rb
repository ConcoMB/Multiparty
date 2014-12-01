#!/usr/bin/env ruby

require_relative 'opts'
require_relative 'parsing_utils'
require_relative 'latice_3d'
require_relative 'particle_3d'

opts = parse_opts({})
t = opts[:t].to_i
W = opts[:w].to_i
H = opts[:h].to_i
D = opts[:d].to_i
R = opts[:r].to_f
Random.new_seed
particles = (1..opts[:n].to_i).map do
  Particle3D.new(Random.rand(0..W), Random.rand(0..H), Random.rand(0..D))
end
ETA = opts[:eta].to_f
off_latice(particles, t, opts[:lead] == 'true', opts[:out_file])
