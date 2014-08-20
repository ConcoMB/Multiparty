class Grid

  attr_accessor :m, :l, :grid, :lm

  def initialize(m, l)
    @m = m
    @l = l
    @ml = m / l
    @grid = Array.new(m) { Array.new(m) { nil } }
    (0..m - 1).each { |i| (0..m - 1).each { |j| @grid[i][j] = Cell.new } }
  end

  def add(particle)
    # puts particle
    # puts "#{(particle.x / @l).to_i} #{(particle.y / @l).to_i}"
    @grid[(particle.x / @ml).to_i][(particle.y / @ml).to_i].add(particle)
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