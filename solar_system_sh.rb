#!/usr/bin/env ruby

require 'byebug'
require_relative 'planet'
require_relative 'opts'
require_relative 'parsing_utils'
require_relative 'solar_dynamics'

opts = parse_opts({})
m_acum = 0
planets = (1..opts[:planets].to_i).map do |i| 
  m = 
  Planet.new(1, 0, 0, 0, 0, Planet::MIN_DISTANCE / 10)
end
planets = [Planet.new(Planer::SUN_MASS)] + planets
calculate(planets, opts[:n].to_i, opts[:out_file])
