#!/usr/bin/env ruby

require 'debugger'
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
  coords = grid.particle_coords(particle)
  i = coords[:x]
  j = coords[:y]
  neighbors = []
  (-1..1).each do |d_i|
    (-1..1).each do |d_j|
      if border
        neighbors += find_neighbors_brute(grid.grid[(i + d_i) % grid.m][(j + d_j) % grid.m].particles, particle, r, border)
      else
        next unless valid_cell(i + d_i, j + d_j, 0, grid.m)
        # puts "cell #{i + d_i} #{j + d_j}, #{grid.grid[i + d_i][j + d_j].particles.size} particles"
        neighbors += find_neighbors_brute(grid.grid[i + d_i][j + d_j].particles, particle, r, border)
      end
    end  
  end
  neighbors
end

def valid_cell(i, j, min, max)
  i >= min && j >= min && i < max && j < max
end

def generate_output_file(particles, neighbors, particle, file)
  file = File.open(file, 'w') 
  file.write("#{particles.size}\ncolor\tx\ty\n")
  particles.each do |p|
    color = p == particle ? 2 : (neighbors.include?(p) ? 1 : 0)
    file.write("#{color}\t#{p.x}\t#{p.y}\n") 
  end
  file.close
end

def infer_m(l, r)
  (l.to_f / r).floor
end

# parse opts
t0 = Time.now
opts = { border: 'false', brute_force: 'false' }
ARGV.each do |e|
  opt = e.split('=')
  opts[opt[0].to_sym] = opt[1] 
end
opts[:border] = opts[:border] == 'true' 
opts[:brute_force] = opts[:brute_force] == 'true' 
# read files
static_content = File.readlines opts[:static_file]
dynamic_content = File.readlines opts[:dynamic_file]
# read particles
particles = []
dynamic_content.each_with_index do |line, i|
  next if i == 0
  pos = line.split(' ')
  particles << Particle.new(i, pos[0].to_f, pos[1].to_f)
end
# fill particles
static_content.each_with_index do |line, i|
  case i.to_i
  when 0
    @n = line.to_i
    particles = particles[0..@n - 1]
  when 1
    @l = line.to_i 
  else
    pos = line.split(' ')
    particles[i - 2].r = pos[0].to_f
    particles[i - 2].color = pos[1].to_f
  end
end
r = opts[:radius].to_f
p_id = opts[:particle_id].to_i
puts '======'
if opts[:brute_force]
  puts 'brute force'
  t1 = Time.now
  neighbors = find_neighbors_brute(particles, particles[p_id - 1], r, opts[:border])
else
  puts 'grid'
  if opts[:cells]
    m = opts[:cells].to_i
  else 
    m = infer_m(@l, r)
    puts "inferred M -> #{m}"
  end
  grid = Grid.new(m, @l)
  particles.each do |p|
    grid.add(p)
  end
  t1 = Time.now
  neighbors = find_neighbors(grid, particles[p_id - 1], r, opts[:border])
end
t2 = Time.now
puts '======'
neighbors.sort!{ |a, b| a.id <=> b.id }
neighbors.each { |p| puts "#{p.id == p_id ? '*' : ' '}#{p}" }
generate_output_file(particles, neighbors, particles[p_id - 1], opts[:out_file]) if opts[:out_file]
puts '======'
puts "Total time elapsed: #{(Time.now - t0) * 1000} s"
puts "Neighbor finding time: #{(t2 - t1) * 1000} s"

