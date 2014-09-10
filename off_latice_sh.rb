#!/usr/bin/env ruby

require 'debugger'
require_relative 'opts'
require_relative 'parsing_utils'
require_relative 'off_latice'

opts = parse_opts({})
particles, l, n = parse_particles(opts[:static_file], opts[:dynamic_file])
revs = opts[:revs].to_i
r = opts[:radius].to_f
eta = opts[:eta].to_f
verbose = opts[:verbose] == 'true'
off_latice(particles, l, n, r, revs, eta, File.open(opts[:out_file], 'w'), verbose)
