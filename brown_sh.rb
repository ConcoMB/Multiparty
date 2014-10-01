#!/usr/bin/env ruby

require 'debugger'
require_relative 'brown'
require_relative 'two_d_particle'
require_relative 'opts'

opts = parse_opts({})
p = init(opts[:n].to_i, opts[:temp].to_f, opts[:show_t] == 'true', opts[:show_big_p] == 'true', opts[:show_v] == 'true')
# id, x, y, r, m, v_x = 0, v_y = 0
# p = [TwoDParticle.new(1, 0.1, 0.25, 0.01, 0.1, -0.1, 0), TwoDParticle.new(2, 0.4, 0.25, 0.01, 0.1, 0.1, 0)]
file = File.open(opts[:out_file], 'w') 
iterate(p, opts[:iter].to_i, file)
file.close