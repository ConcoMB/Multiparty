require 'byebug'
require_relative 'lennard_jones_particle'

def calculate(particles, n, delta_t, file_name)
  @delta_t = delta_t
  @delta_t_2 = delta_t ** 2
  @delta_print = 0.1 / delta_t
  @delta_t_amounts = 1 / delta_t
  @tp = 0
  file = file_name ? File.open(file_name, 'w') : nil
  @walls = (0..LennardJonesParticle::WIDTH).step(1).map { |i| LennardJonesParticle.new(0, i, 0, 0, 0, true) } +
    (0..LennardJonesParticle::WIDTH).step(1).map { |i| LennardJonesParticle.new(0, i, LennardJonesParticle::HEIGHT, 0, 0, true) } +
    (1..LennardJonesParticle::HEIGHT - 1).step(1).map { |i| LennardJonesParticle.new(0, LennardJonesParticle::WIDTH, i, 0, 0, true) } +
    (1..LennardJonesParticle::HEIGHT - 1).step(1).map { |i| LennardJonesParticle.new(0, 0, i, 0, 0, true) } +
    (1..90).step(1).map { |i| LennardJonesParticle.new(0, LennardJonesParticle::WIDTH / 2, i, 0, 0, true) } +
    (110..199).step(1).map { |i| LennardJonesParticle.new(0, LennardJonesParticle::WIDTH / 2, i, 0, 0, true) }

  @energy_file = File.open("./files/energy#{n}_#{delta_t}.txt", 'w') 
  v_mid_file = File.open("./files/velocity_mid#{n}_#{delta_t}.txt", 'w') 
  v_end_file = File.open("./files/velocity_end#{n}_#{delta_t}.txt", 'w')
  v_init_file = File.open("./files/velocity_beg#{n}_#{delta_t}.txt", 'w') 
  @amount_file = File.open("./files/amounts#{n}_#{delta_t}.txt", 'w')
  @t_amounts = 0
  particles_old = particles
  particles.each { |p| p.force(particles) }
  particles_current = particles.map do |p|
    x = p.x + @delta_t * p.vx + @delta_t_2 * p.ax / 2
    vx = p.vx + @delta_t / p.m * p.fx
    y = p.y + @delta_t * p.vy + @delta_t_2 * p.ay / 2
    vy = p.vy + @delta_t / p.m * p.fy
    LennardJonesParticle.new(p.id, x, y, vx, vy)
  end
  print_v(particles, v_init_file)
  particles_new = []
  print(particles, file)
  print(particles_current, file)
  t = @delta_t * 2
  cut_condition = n == 0 ? particles_current.select { |p| p.x > LennardJonesParticle::WIDTH / 2 }.size < particles_current.size / 2 : t < n
  while cut_condition do
    particles_current.each { |p| p.force(particles_current) }
    particles_current.each_with_index do |p, i|
      old_p = particles_old[i]
      #beeman
      x = p.x + p.vx * @delta_t + 1.0 / 6 * (4 * p.ax - old_p.ax) * @delta_t_2
      y = p.y + p.vy * @delta_t + 1.0 / 6 * (4 * p.ay - old_p.ay) * @delta_t_2
      part = LennardJonesParticle.new(p.id, x, y, p.vx, p.vy)
      part.force(particles_current)
      vx = p.vx + 1.0 / 6 * (2 * part.ax + 5 * p.ax - old_p.ax) * @delta_t
      vy = p.vy + 1.0 / 6 * (2 * part.ay + 5 * p.ay - old_p.ay) * @delta_t
      particles_new << LennardJonesParticle.new(p.id, x, y, vx, vy)
    end
    print(particles_new, file)
    particles_old = particles_current
    particles_current = particles_new
    particles_new = []
    t += @delta_t
    print_v(particles_current, v_mid_file) if n != 0 && t >= n / 2 && t - @delta_t < n / 2
    print_amounts(particles_current)
    cut_condition = n == 0 ? particles_current.select { |p| p.x > LennardJonesParticle::WIDTH / 2 }.size < particles_current.size / 2 : t < n
    puts t
    puts particles_current.select { |p| p.x > LennardJonesParticle::WIDTH / 2 }.size
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

def print_amounts(particles)
  @t_amounts += 1
  return unless @t_amounts == @delta_t_amounts
  @t_amounts = 0
  @amount_file.write("#{particles.select{ |p| p.x < LennardJonesParticle::WIDTH / 2 }.size}\n")
end

def print(particles, file)
  @tp += 1
  return unless @tp == @delta_print
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