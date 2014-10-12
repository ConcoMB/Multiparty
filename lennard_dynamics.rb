require 'byebug'
require_relative 'lennard_jones_particle'

DELTA_T = 0.25
DELTA_T_2 = DELTA_T ** 2

def calculate(particles, n, file_name)
  file = file_name ? File.open(file_name, 'w') : nil
  @energy_file = File.open('./files/energy.txt', 'w') 
  v_mid_file = File.open('./files/velocity_mid.txt', 'w') 
  v_end_file = File.open('./files/velocity_end.txt', 'w') 

  particles_old = particles
  particles.each { |p| p.force(particles) }
  particles_current = particles.map do |p|
    x = p.x + DELTA_T * p.vx + DELTA_T_2 / (2 * p.m) * p.fx
    vx = p.vx + DELTA_T / p.m * p.fx
    y = p.y + DELTA_T * p.vy + DELTA_T_2 / (2 * p.m) * p.fy
    vy = p.vy + DELTA_T / p.m * p.fy
    LennardJonesParticle.new(x, y, vx, vy)
  end
  particles_new = []
  print(particles_old, file)
  print(particles_current, file)
  t = DELTA_T * 2
  while t < n do
    particles_current.each { |p| p.force(particles_current) }
    particles_current.each_with_index do |p, i|
      old_p = particles_old[i]
      x = 2 * p.x - old_p.x + DELTA_T_2 / p.m * p.fx
      vx = x - old_p.x / (2 * DELTA_T)
      y = 2 * p.y - old_p.y + DELTA_T_2 / p.m * p.fy
      vy = y - old_p.y / (2 * DELTA_T)
      particles_new << LennardJonesParticle.new(x, y, vx, vy)
    end
    print(particles_new, file)
    particles_old = particles_current
    particles_current = particles_new
    particles_new = []
    t += DELTA_T
    print_v(particles, v_mid_file) if t == n / 2
    puts t
  end
  print_v(particles, v_end_file)
  file.close if file
  @energy_file.close
  v_mid_file.close
  v_end_file.close
end

def print_v(particles, f) 
  particles.each { |p| f.write("#{p.vx ** 2 + p.vy ** 2}\n") }

end

def print(particles, file)
  if file 
    file.write("#{particles.size + 184}\ncolor\tx\ty\n1\t0\t0\n1\t#{LennardJonesParticle::WIDTH}\t#{LennardJonesParticle::HEIGHT}\n")
    particles.each {|p| file.write("1\t#{p.x}\t#{p.y}\n") } 
    (0..90).each { |i| file.write("0\t#{LennardJonesParticle::WIDTH / 2}\t#{i}\n") }
    (110..200).each { |i| file.write("0\t#{LennardJonesParticle::WIDTH / 2}\t#{i}\n") }
  else
    particles.each { |p| puts "#{p.x}\t#{p.y}" }
  end
  ec = particles.reduce(0) { |a, e| a + e.cynematic }
  ep = particles.reduce(0) { |a, e| a + e.potential(particles) }
  @energy_file.write("#{ec}\t#{ep}\n")
end