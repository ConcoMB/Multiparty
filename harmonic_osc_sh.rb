#!/usr/bin/env ruby

require 'byebug'
require_relative 'harmonic_oscilator_particle'
require_relative 'opts'
require_relative 'parsing_utils'
require_relative 'harmonic_dynamics'

opts = parse_opts({})
calculate(opts[:method], opts[:n].to_i, opts[:out_file])
