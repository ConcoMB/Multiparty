#!/usr/bin/env ruby

require_relative 'particle'
require_relative 'grid'
require_relative 'cell'

def find_neighbors_brute(particles, particle, r, border)
  particles.select do |e| 
    delta_x = e.x - particle.x
    delta_y = e.y - particle.y
    if border
      delta_x = @l - delta_x if delta_x > @l / 2 
      delta_y = @l - delta_y if delta_y > @l / 2 
    end  
    (Math.sqrt(delta_x ** 2 + delta_y ** 2) - (e.r + particle.r)) < r
  end
end

def find_neighbors(grid, particle, r, border)
  i = (particle.x / grid.l).to_i
  j = (particle.y / grid.l).to_i
  neighbors = []
  (-1..1).each do |d_i|
    (-1..1).each do |d_j|
      if border
        neighbors << find_neighbors_brute(grid.grid[(i + d_i) % grid.m][(j + d_j) % grid.m].particles, particle, r, border)
      else
        next unless valid_cell(i + d_i, j + d_j, 0, grid.m)
        neighbors << find_neighbors_brute(grid.grid[i + d_i][j + d_j].particles, particle, r, border)
      end
    end  
  end
  neighbors
end

def valid_cell(i, j, min, max)
  i >= min && j >= min && i < max && j < max
end

opts = { border: 'false' }
ARGV.each do |e|
  opt = e.split('=')
  opts[opt[0].to_sym] = opt[1] 
end
opts[:border] = opts[:border] == 'true' 
static_content = File.readlines opts[:static_file]
dynamic_content = File.readlines opts[:dynamic_file]
particles = []
m = opts[:cells].to_i
r = opts[:radius].to_f
p_id = opts[:particle_id].to_i
dynamic_content.each_with_index do |line, i|
  pos = line.split(' ') 
  particles << Particle.new(i + 1, pos[0].to_f, pos[1].to_f)
end
static_content.each_with_index do |line, i|
  case i.to_i
  when 0
    @n = line.to_i
  when 1
    @l = line.to_i 
  else
    pos = line.split(' ') 
    particles[i - 2].r = pos[0].to_f
    particles[i - 2].color = pos[1].to_f
  end
end
grid = Grid.new(m, @l)
particles.each do |p|
  grid.add(p)
end
puts 'brute'
puts find_neighbors_brute(particles, particles[p_id - 1], r, opts[:border])

puts 'grid'
puts find_neighbors(grid, particles[p_id - 1], r, opts[:border])
