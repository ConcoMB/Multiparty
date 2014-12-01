require 'byebug'
require_relative 'particle_3d'

DELTA_P = 5
DELTA_S = 5
SNAP_LENGTH = 200 / DELTA_S
VA_LEADER_CUT = 0.9
DELTA_FLIP = 1000

def off_latice(particles, t_cut, with_leader, out_file)
  @file = File.open(out_file, 'w')
  @particles = particles
  @with_leader = with_leader
  t = 0
  done = t_cut == 0 ? false : t >= t_cut
  @old_snaps = []
  @t_snaps = 0
  @t_print = 0
  last_flip_t = 0
  until done do
    print
    cell_index
    # particles.each { |p| p.alter(particles.select { |q| q != p && p.distance(q) < R }) }
    @particles.each_with_index do |p, i| 
      next if with_leader && i == 0
      p.alter(neighbours p)
    end
    @particles.each { |p| p.move(1) }
    t += 1
    # puts t
    this_va = va
    puts this_va
    handle_snaps
    done = t_cut == 0 ? false : t >= t_cut
    if with_leader && this_va > VA_LEADER_CUT && t > last_flip_t + DELTA_FLIP
      last_flip_t = t
      particles[0].phi = (particles[0].phi + Random.rand((Math::PI / 2)..(Math::PI * 3 / 2))) % (2 * Math::PI) 
      particles[0].theta = (particles[0].theta + Random.rand((Math::PI / 4)..(Math::PI * 3 / 4))) % (Math::PI) 
    end
  end
  @file.close
end

def handle_snaps
  @t_snaps += 1
  return unless @t_snaps == DELTA_S
  @t_snaps = 0 
  snap = @particles.map { |p| Particle3D.new(p.x, p.y, p.z, p.theta, p.phi) }
  @old_snaps = [snap] + @old_snaps
  @old_snaps = @old_snaps[0..SNAP_LENGTH]
end

def va
  vx = @particles.reduce(0) { |a, e| a + e.vx }
  vy = @particles.reduce(0) { |a, e| a + e.vy }
  vz = @particles.reduce(0) { |a, e| a + e.vz }
  Math.sqrt(vx ** 2 + vy ** 2 + vz ** 2) / (@particles.size * Particle3D::V)
end

def print
  @t_print += 1
  return unless @t_print == DELTA_P
  @t_print = 0 
  snaps_size = @old_snaps.reduce(0) { |a, e| a + e.size }
  @file.write("#{@particles.size + 2 + snaps_size}\nr\tg\tb\tx\ty\tz\trad\n")
  @file.write("0\t0\t0\t0\t0\t0\t0.1\n")
  @file.write("0\t0\t0\t#{W}\t#{H}\t#{D}\t0.1\n")
  @particles.each_with_index do |p, i|
    if @with_leader && i == 0
      @file.write("1\t1\t1\t#{p.x}\t#{p.y}\t#{p.z}\t0.5\n")
    else 
      @file.write("#{p.red}\t#{p.green}\t#{p.blue}\t#{p.x}\t#{p.y}\t#{p.z}\t0.5\n") 
    end
  end 
  @old_snaps.each do |snap| 
    snap.each_with_index do |p, i| 
      if @with_leader && i == 0
        @file.write("1\t1\t1\t#{p.x}\t#{p.y}\t#{p.z}\t0.05\n") 
      else 
        @file.write("#{p.red}\t#{p.green}\t#{p.blue}\t#{p.x}\t#{p.y}\t#{p.z}\t0.05\n") 
      end
    end
  end 
end

def cell_index
  @cell_index = []
  height_cells.times do |i|
    @cell_index[i] = []
    width_cells.times do |j|
      @cell_index[i][j] = []
      depth_cells.times do |k|
        @cell_index[i][j][k] = []
      end
    end
  end
  @particles.each do |particle|
    i, j, k = particle_index(particle)
    byebug if @cell_index[i].nil? || @cell_index[i][j].nil? || @cell_index[i][j][k].nil?
    @cell_index[i][j][k] << particle
  end
  @cell_index
end

def neighbours(particle)
  i, j, k = particle_index(particle)
  n = Set.new
  n_i = [(i - 1) % width_cells, i, (i + 1) % width_cells]
  n_j = [(j - 1) % height_cells, j, (j + 1) % height_cells]
  n_k = [(k - 1) % depth_cells, k, (k + 1) % depth_cells]
  n_i.each do |a|
    n_j.each do |b|
      n_k.each do |c|
        byebug if @cell_index[a].nil? || @cell_index[a][b].nil? || @cell_index[a][b][c].nil?
        particles = @cell_index[a][b][c]
        byebug if particles == nil
        particles.each do |p|
          n << p if (particle != p) && particle.distance(p) <= R
        end
      end
    end
  end
  n
end

def particle_index(particle)
  [(particle.x / cell_width).to_i, 
   (particle.y / cell_height).to_i, 
   (particle.z / cell_depth).to_i]
end

def height_cells
  (H.to_f / R).floor
end

def width_cells
  (W.to_f / R).floor
end

def depth_cells
  (D.to_f / R).floor
end

def cell_width
  W.to_f / width_cells
end

def cell_height
  H.to_f / height_cells
end

def cell_depth
  D.to_f / depth_cells
end