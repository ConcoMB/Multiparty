require 'byebug'
require_relative 'silo_particle'

X_MARGIN = 20
Y_MARGIN = 40
WALL_R = 0.3
DELTA_PRINT = 0.1

def calculate(particles, walls, delta_t, l, w, out_file)
  @l = l
  @w = w
  t = 0
  @tp = 0
  if delta_t
    @delta_t = delta_t
  else
    @delta_t = 0.01 * Math.sqrt(SiloParticle::M / SiloParticle::KN)
  end
  @tp_tresh = DELTA_PRINT / @delta_t
  @delta_t_2 = @delta_t ** 2
  file = File.new(out_file, 'w')
  print(particles, walls, file)
  particles_old = particles
  particles.each { |p| p.force(particles) }
  particles_current = particles.map do |p|
    x = p.x + @delta_t * p.vx + @delta_t_2 * p.ax / 2
    vx = p.vx + @delta_t / p.m * p.fx
    y = p.y + @delta_t * p.vy + @delta_t_2 * p.ay / 2
    vy = p.vy + @delta_t / p.m * p.fy
    SiloParticle.new(p.id, p.r, x, y, vx, vy)
  end
  particles_new = []
  any_particle_in_silo = true
  while any_particle_in_silo do
  # (1..100).each do
    particles_current.each { |p| p.force(particles_current) }
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
      particles_new << SiloParticle.new(p.id, p.r, x, y, vx, vy)
    end
    # particles_new = particles_new.select { |p| p.y > 0 }
    print(particles_new, walls, file)
    particles_old = particles_current
    particles_current = particles_new
    particles_new = []
    t += @delta_t
    puts t
    # puts "#{particles_old.first.fx} #{particles_old.first.fy}"
    any_particle_in_silo = particles_current.any? { |p| p.y > 0 }
  end

  file.close
end

def print(particles, walls, file)
  @tp += 1
  return if @tp < @tp_tresh
  @tp = 0
  max_v = particles.reject { |p| p.v_2.nan? }.map(&:v_2).max
  file.write("#{particles.size + walls.size + 2}\nR\tG\tB\tr\tx\ty\n0\t1\t0\t#{WALL_R}\t#{-X_MARGIN}\t#{-Y_MARGIN}\n0\t1\t0\t#{WALL_R}1\t#{@w + X_MARGIN}\t#{@l + Y_MARGIN}\n")
  particles.each {|p| file.write("#{red(p, max_v)}\t0\t#{blue(p, max_v)}\t#{p.r}\t#{p.x}\t#{p.y}\n") }
  walls.each {|p| file.write("0\t1\t0\t#{WALL_R}\t#{p.x}\t#{p.y}\n") }
end

def red(particle, max_v)
  return 0 if max_v == 0
  particle.v_2 / max_v
end

def blue(particle, max_v)
  1 - red(particle, max_v)
end
