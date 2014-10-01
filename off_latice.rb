require_relative 'neighborhood'

VELOCITY_DEF = 0.3
COLOR_MAX = 1

def calculate_tita(particle, neighbors, interval)
  sum = neighbors.reduce(particle.tita) { |a, e| a + e.tita }
  avg = sum.to_f / (neighbors.size + 1)
  noise = Random.rand(interval)
  (avg + noise) % (2 * Math::PI)
end

def store_snapshot(i, particles, file)
  file.write("#{particles.size}\nx\ty\tv_x\tv_y\tr\tg\tb\n")
  particles.each { |p| file.write("#{p.x}\t#{p.y}\t#{p.v_x}\t#{p.v_y}\t#{r(p.tita)}\t0\t#{b(p.tita)}\n") }
end

def calculate_stuff(particles)
  avg = particles.reduce(0) { |a, e| a + e.tita } / particles.size
  variance = particles.reduce(0) { |a, e| a + (e.tita - avg) ** 2 } / particles.size
  sum_x = particles.reduce(0) { |a, e| a + e.v_x }
  sum_y = particles.reduce(0) { |a, e| a + e.v_y }
  mod = Math.sqrt(sum_x ** 2 + sum_y ** 2) / (particles.size * VELOCITY_DEF)
  puts "#{avg}\t#{variance}\t#{mod}"
end

def r(tita)
  tita * COLOR_MAX / (2 * Math::PI)
end

def b(tita)
  COLOR_MAX - (tita * COLOR_MAX / (2 * Math::PI))
end

def off_latice(particles, l, n, r, revs, eta, out_file, verbose)
  particles.each do |p| 
    p.v = VELOCITY_DEF
    p.tita = Random.rand(0.0..(2 * Math::PI))
  end
  puts "Promedio\tVarianza\tModulo" if verbose
  interval = ((-eta / 2)..(eta / 2))
  m = infer_m(l, r)
  (0..revs).each do |i|
    store_snapshot(i, particles, out_file)
    calculate_stuff(particles) if verbose
    particles.each do |p|
      p.move(1, l)
      neigh = find_neighbors(particles, p.id, r, l, m, false, true)
      p.tita = calculate_tita(p, neigh, interval)
    end
  end
  out_file.close
end