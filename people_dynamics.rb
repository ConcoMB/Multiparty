require 'byebug'
require_relative 'people_particle'

DELTA_PRINT = 0.1
CUT_R = PeopleParticle::R * 2

def calculate(particles, goals, delta_t, fight, out_file)
  @file = File.new(out_file, 'w')
  @goals = goals
  if delta_t
    @delta_t = delta_t
  else
    @delta_t = 0.1 * Math.sqrt(PeopleParticle::M / PeopleParticle::KN)
  end
  t = 0
  @tp = 0
  @tp_tresh = DELTA_PRINT / @delta_t
  @delta_t_2 = @delta_t ** 2
  print(particles)
  particles_old = particles
  @cell_index = cell_index(particles)
  particles.each { |p| p.force(neighbours(p)) }
  # particles.each { |p| p.force(particles) }
  particles_current = particles.map do |p|
    x = p.x + @delta_t * p.vx + @delta_t_2 * p.ax / 2
    vx = p.vx + @delta_t / p.m * p.fx
    y = p.y + @delta_t * p.vy + @delta_t_2 * p.ay / 2
    vy = p.vy + @delta_t / p.m * p.fy
    PeopleParticle.new(p.id, p.red, x, y, false, vx, vy, p.vd)
  end
  particles_new = []
  cut_condition = true
  while cut_condition do
    @cell_index = cell_index(particles_current)
    particles_current.each { |p| p.force(neighbours(p)) }
    particles_current.each { |p| p.fight(neighbours(p)) } if fight
    # particles_current.each { |p| p.force(particles_current) }
    # particles_current.each { |p| p.fight(particles_current) } if fight

    particles_current.each_with_index do |p, i|  
      old_p = particles_old[i]
      #beeman
      # x = p.x + p.vx * @delta_t + 1.0 / 6 * (4 * p.ax - old_p.ax) * @delta_t_2
      # y = p.y + p.vy * @delta_t + 1.0 / 6 * (4 * p.ay - old_p.ay) * @delta_t_2
      # part = SiloParticle.new(p.id, p.r, x, y, p.vx, p.vy)
      # part.force(particles_current)
      # vx = p.vx + 1.0 / 6 * (2 * part.ax + 5 * p.ax - old_p.ax) * @delta_t
      # vy = p.vy + 1.0 / 6 * (2 * part.ay + 5 * p.ay - old_p.ay) * @delta_t
      # particles_new << SiloParticle.new(p.id, p.r, x, y, vx, vy)
      # euler
      # x = p.x + @delta_t * p.vx + @delta_t_2 / (2 * p.m) * p.fx
      # vx = p.vx + @delta_t / p.m * p.fx
      # y = p.y + @delta_t * p.vy + @delta_t_2 / (2 * p.m) * p.fy
      # vy = p.vy + @delta_t / p.m * p.fy
      # particles_new << SiloParticle.new(p.id, p.r, x, y, vx, vy)
      # verlet
      x = 2 * p.x - old_p.x + p.ax * @delta_t_2
      y = 2 * p.y - old_p.y + p.ay * @delta_t_2
      vx = (x - old_p.x) / (2 * @delta_t)
      vy = (y - old_p.y) / (2 * @delta_t)
      particles_new << PeopleParticle.new(p.id, p.red, x, y, p.dead, vx, vy, p.vd)      
    end
    # particles_new = particles_new.select { |p| p.y > 0 }
    print(particles_new)
    particles_old = particles_current
    particles_current = particles_new
    particles_new = []
    t += @delta_t
    puts t
  end
  @file.close
end

def print(particles)
  @tp += 1
  return if @tp < @tp_tresh
  @tp = 0
  @file.write("#{particles.size + @goals.size}\nR\tG\tB\tr\tx\ty\n")
  (particles + @goals).each { |p| @file.write("#{p.red * (p.dead ? 0.5 : 1)}\t0\t#{p.blue * (p.dead ? 0.5 : 1)}\t#{p.r}\t#{p.x}\t#{p.y}\n") }
end


def cell_index(particles)
  ci = []
  height_cells.times do |i|
    ci[i] = []
    width_cells.times do |j|
      ci[i][j] = []
    end
  end
  particles.each do |particle|
    row, col = particle_index(particle)
    next if ci[row] == nil || ci[row][col] == nil
    ci[row][col] << particle
  end
  ci
end

def neighbours(particle)
  row, col = particle_index(particle)
  n = Set.new
  n_rows, n_cols = [], []
  n_rows << row
  n_cols << col
  n_rows << row - 1 if row > 0
  n_rows << row + 1 if row < height_cells - 1
  n_cols << col - 1 if col > 0
  n_cols << col + 1 if col < width_cells - 1
  n_rows.each do |r|
    n_cols.each do |c|
      next if @cell_index[r] == nil
      particles = @cell_index[r][c]
      next if particles == nil
      particles.each do |p|
        n << p if (particle != p) && particle.distance(p) <= CUT_R
      end
    end
  end
  n
end

def particle_index(particle)
  [ (particle.y / cell_height).to_i, (particle.x / width_cells).to_i ]
end

def height_cells
  (H.to_f / CUT_R).floor
end

def width_cells
  ((W * 2 + D).to_f / CUT_R).floor
end

def cell_width
  (W * 2 + D).to_f / width_cells
end

def cell_height
  H.to_f / height_cells
end