require 'byebug'
require_relative 'lennard_jones_particle'

DELTA_T = 0.0001
DELTA_T_2 = DELTA_T ** 2
DELTA_PRINT = 100

def calculate(particles, n, file_name)
  @tp = 0
  file = file_name ? File.open(file_name, 'w') : nil
  @walls = (0..LennardJonesParticle::WIDTH).step(1).map { |i| LennardJonesParticle.new(0, i, 0, 0, 0, true) } +
    (0..LennardJonesParticle::WIDTH).step(1).map { |i| LennardJonesParticle.new(0, i, LennardJonesParticle::HEIGHT, 0, 0, true) } +
    (1..LennardJonesParticle::HEIGHT - 1).step(1).map { |i| LennardJonesParticle.new(0, LennardJonesParticle::WIDTH, i, 0, 0, true) } +
    (1..LennardJonesParticle::HEIGHT - 1).step(1).map { |i| LennardJonesParticle.new(0, 0, i, 0, 0, true) } +
    (1..90).step(1).map { |i| LennardJonesParticle.new(0, LennardJonesParticle::WIDTH / 2, i, 0, 0, true) } +
    (110..199).step(1).map { |i| LennardJonesParticle.new(0, LennardJonesParticle::WIDTH / 2, i, 0, 0, true) }

  @energy_file = File.open('./files/energy.txt', 'w') 
  v_mid_file = File.open('./files/velocity_mid.txt', 'w') 
  v_end_file = File.open('./files/velocity_end.txt', 'w') 

  particles_old = particles
  particles.each { |p| p.force(particles) }
  particles_current = particles.map do |p|
    x = p.x + DELTA_T * p.vx + DELTA_T_2 * p.ax / 2
    vx = p.vx + DELTA_T / p.m * p.fx
    y = p.y + DELTA_T * p.vy + DELTA_T_2 * p.ay / 2
    vy = p.vy + DELTA_T / p.m * p.fy
    LennardJonesParticle.new(p.id, x, y, vx, vy)
  end

  particles_new = []
  print(particles, file)
  print(particles_current, file)
  t = DELTA_T * 2
  while t < n do
    particles_current.each { |p| p.force(particles_current) }
    particles_current.each_with_index do |p, i|
      old_p = particles_old[i]
      # verlet
      # x = 2 * p.x - old_p.x + DELTA_T_2 / p.m * p.fx
      # vx = x - old_p.x / (2 * DELTA_T)
      # y = 2 * p.y - old_p.y + DELTA_T_2 / p.m * p.fy
      # vy = y - old_p.y / (2 * DELTA_T)
      # particles_new << LennardJonesParticle.new(p.id, x, y, vx, vy)
      #beeman
      # x = p.x + p.vx * DELTA_T + 1.0 / 6 * (4 * p.ax - old_p.ax) * DELTA_T_2
      # y = p.y + p.vy * DELTA_T + 1.0 / 6 * (4 * p.ay - old_p.ay) * DELTA_T_2
      # part = LennardJonesParticle.new(p.id, x, y, p.vx, p.vy)
      # part.force(particles_current)
      # vx = p.vx + 1.0 / 6 * (2 * part.ax + 5 * p.ax - old_p.ax) * DELTA_T
      # vy = p.vy + 1.0 / 6 * (2 * part.ay + 5 * p.ay - old_p.ay) * DELTA_T
      # particles_new << LennardJonesParticle.new(p.id, x, y, vx, vy)
      #leap
      vx = p.vx + DELTA_T * p.fx / p.m
      vy = p.vy + DELTA_T * p.fy / p.m
      x = p.x + DELTA_T * vx
      y = p.y + DELTA_T * vy
      particles_new << LennardJonesParticle.new(p.id, x, y, vx, vy)
    end
    print(particles_new, file)
    particles_old = particles_current
    particles_current = particles_new
    particles_new = []
    t += DELTA_T
    print_v(particles_current, v_mid_file) if t == n / 2
    puts t
  end
  print_v(particles_current, v_end_file)
  file.close if file
  @energy_file.close
  v_mid_file.close
  v_end_file.close
end

def print_v(particles, f) 
  particles.each { |p| f.write("#{p.vx ** 2 + p.vy ** 2}\n") }
end

def print(particles, file)
  @tp += 1
  return unless @tp == DELTA_PRINT
  @tp = 0
  if file 
    file.write("#{particles.size + @walls.size}\ncolor\tx\ty\n")
    particles.each { |p| 
      file.write("#{p.id}\t#{p.x}\t#{p.y}\n") } 
    @walls.each { |p| file.write("#{p.id}\t#{p.x}\t#{p.y}\n") } 
  else
    particles.each { |p| puts "#{p.x}\t#{p.y}" }
  end
  ec = particles.reduce(0) { |a, e| a + e.cynematic }
  ep = particles.reduce(0) { |a, e| a + e.potential(particles) }
  @energy_file.write("#{ec}\t#{ep}\n")
end