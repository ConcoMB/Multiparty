#!/usr/bin/env ruby

require 'debugger'
require_relative 'brown'
require_relative 'two_d_particle'
require_relative 'opts'

opts = parse_opts({})
# p = init(opts[:n].to_i)
p = [TwoDParticle.new(1, 0.25, 0.25, 0.01, -0.1, -0.1)]
file = File.open(opts[:out_file], 'w') 
iterate(p, opts[:iter].to_i, file)
file.close