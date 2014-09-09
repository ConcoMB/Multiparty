#!/usr/bin/env ruby

require 'debugger'
require_relative 'neighborhood'
require_relative 'opts'
require_relative 'parsing_utils'

VELOCITY_DEF = 0.3
COLOR_MAX = 1

def calculate_tita(particle, neighbors, interval)
  sum = neighbors.reduce(particle.tita) { |a, e| a + e.tita }
  avg = sum.to_f / (neighbors.size + 1)
  noise = Random.rand(interval)
  (avg + noise) % (2 * Math::PI)
end

def store_snapshot(i, particles, file)
  file.write("#{particles.size}\nx\ty\tv_x\tv_y\tr\tg\tb\n")
  particles.each { |p| file.write("#{p.x}\t#{p.y}\t#{p.v_x}\t#{p.v_y}\t#{r(p.tita)}\t0\t#{b(p.tita)}\n") }
end

def calculate_stuff(particles)
  avg = particles.reduce(0) { |a, e| a + e.tita } / particles.size
  variance = particles.reduce(0) { |a, e| a + (e.tita - avg) ** 2 } / particles.size
  puts "#{avg}\t#{variance}"
end

def r(tita)
  tita * COLOR_MAX / (2 * Math::PI)
end

def b(tita)
  COLOR_MAX - (tita * COLOR_MAX / (2 * Math::PI))
end

opts = parse_opts({})
particles, l, n = parse_particles(opts[:static_file], opts[:dynamic_file])
particles.each do |p| 
  p.v = VELOCITY_DEF
  p.tita = Random.rand(0.0..(2 * Math::PI))
end
revs = opts[:revs].to_i
r = opts[:radius].to_f
eta = opts[:eta].to_f
verbose = opts[:verbose] == 'true'
puts "Promedio\tVarianza" if verbose
interval = ((-eta / 2)..(eta / 2))
file = File.open(opts[:out_file], 'w')
m = infer_m(l, r)
(0..revs).each do |i|
  store_snapshot(i, particles, file)
  calculate_stuff(particles) if verbose
  particles.each do |p|
    p.move(1, l)
    neigh = find_neighbors(particles, p.id, r, m, l, false, true)
    p.tita = calculate_tita(p, neigh, interval)
  end
end
file.close

