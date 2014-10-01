#!/usr/bin/env ruby

require 'debugger'
require_relative 'tita_particle'
require_relative 'grid'
require_relative 'cell'
require_relative 'neighborhood'
require_relative 'opts'
require_relative 'parsing_utils'

# parse opts
t0 = Time.now
opts = { border: 'false', brute_force: 'false' }
opts = parse_opts(opts)
opts[:border] = opts[:border] == 'true' 
opts[:brute_force] = opts[:brute_force] == 'true' 
particles, l, n = parse_particles(opts[:static_file], opts[:dynamic_file])
p_id = opts[:particle_id].nil? ? nil : opts[:particle_id].to_i
# puts '======'
find_neighbors(particles, p_id, opts[:radius].to_f, l, opts[:cells], opts[:brute_force], 
               opts[:border], opts[:out_file])

