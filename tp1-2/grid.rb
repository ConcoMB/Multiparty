require 'debugger'
require_relative 'cell'

class Grid

  attr_accessor :m, :l, :grid, :ml

  def initialize(m, l)
    @m = m
    @l = l
    @ml = m.to_f / l
    @grid = Array.new(m) { Array.new(m) { nil } }
    (0..m - 1).each { |i| (0..m - 1).each { |j| @grid[i][j] = Cell.new } }
  end

  def add(particle)
    coords = particle_coords(particle)
    @grid[coords[:x]][coords[:y]].add(particle)
  end

  def particle_coords(particle)
    { x: (particle.x * @ml).to_i, y: (particle.y * @ml).to_i }
  end

  def to_s
    puts @grid
  end

  def size
    x = 0
    (0..m - 1).each { |i| (0..m - 1).each { |j| x += @grid[i][j].particles.size } }
    x
  end

end