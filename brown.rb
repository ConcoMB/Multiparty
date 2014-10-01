
require 'debugger'
require_relative 'two_d_particle'
require_relative 'grid'
require_relative 'cell'
require_relative 'collision_pair'
require_relative 'neighborhood'

L = 0.5
R1 = 0.005
M1 = 1
R2 = 0.05
M2 = 20
V1_MIN = -0.1
V1_MAX = 0.1
V2 = 0
DELTA_T = 0.001
DELTA_PRINT = 50
EPS = 0

def init(n, temp, show_t = false, show_big_p = false, show_v = false)
  @show_t = show_t 
  @show_big_p = show_big_p
  @show_v = show_v
  @show_t_file = File.open('./files/show_t.txt', 'w') if @show_t
  @show_big_p_file = File.open('./files/show_big_p.txt', 'w') if @show_big_p
  @show_v_file = File.open('./files/show_v.txt', 'w') if @show_v
  @tp = 0 
  particles = [TwoDParticle.new(1, L / 2, L / 2, R2, M2)] #the big one
  n.times do |i|
    p = nil
    loop do 
      p = TwoDParticle.new(i - 1, random_pos(R1), random_pos(R1), R1, M1, random_v(temp), random_v(temp))
      break unless is_superposed(p, particles)
    end 
    particles << p
  end
  particles
end

def iterate(particles, n, file)
  t = 0
  collision_pairs = []
  print(particles, file)
  loop do
    t_c, collision_pairs = find_collisions(particles)
    if t_c.nil?
      t = handle_movement(particles, DELTA_T, t, file)
    else
      while t_c > DELTA_T do 
        t = handle_movement(particles, DELTA_T, t, file)
        t_c -= DELTA_T
        return close(particles) if t >= n 
      end
      t = handle_movement(particles, t_c, t)
      collision_pairs.each { |pair| handle_collision(pair) }
      print_collision_t(collision_pairs, t) if @show_t 
      t = handle_movement(particles, DELTA_T - t_c, t, file)
    end
    puts t
    break if t >= n 
  end
  close(particles)
end

def close(particles)
  @show_t_file.close if @show_t_file
  @show_big_p_file.close if @show_big_p_file
  print_v(particles, nil) if @show_v
  @show_v_file.close if @show_v
end

def handle_movement(particles, t, t_acum, file = nil)
  particles.each { |p| p.move(t) }
  if file
    @tp += 1
    if @tp == DELTA_PRINT
      # puts "t: #{ t_acum + t}"
      print(particles, file)
      @tp = 0
    end
    # print_v(particles, t) if @show_v
    print_big_p(particles[0]) if @show_big_p
  end
  t_acum + t
end

def find_collisions(particles)
  t_walls, collision_pairs_walls = find_collisions_wall(particles)
  t_particles, collision_pairs_particles = find_collisions_particles(particles)
  if t_walls + EPS >= t_particles && t_walls - EPS <= t_particles
    return [t_walls, collision_pairs_walls + collision_pairs_particles] 
  end
  return [t_walls, collision_pairs_walls] if t_walls < t_particles
  [t_particles, collision_pairs_particles]
end

def find_collisions_particles(particles)
  t = Float::INFINITY
  pairs = []
  particles.each do |p|
    # def find_neighbors(particles, particle_id, r, l, m = nil, brute_force = false, border = false, out_file = nil)
    neigh = find_neighbors(particles, p.id, L.to_f / 4, L, nil, true)
    next if neigh.empty?
    neigh.each do |q|
      next if pairs.any? { |e| (e.a == p && e.b == q) || (e.b == p && e.a == q) }
      pair = CollisionPair.new(p, q)
      next if (pair.d < 0 || pair.delta_v_delta_r >= 0) 
      t_c = - (pair.delta_v_delta_r + Math.sqrt(pair.d)) / pair.delta_v_delta_v
      pairs << pair if t_c == t 
      if t_c < t
        pairs = [pair]
        t = t_c
      end
    end
  end
  [t, pairs]
end

def find_collisions_wall(particles)
  t_x = particles.map { |p| p.v_x > 0 ? (L - p.r - p.x).to_f / p.v_x : (p.r - p.x).to_f / p.v_x }
  t_y = particles.map { |p| p.v_y > 0 ? (L - p.r - p.y).to_f / p.v_y : (p.r - p.y).to_f / p.v_y }
  all_t = (t_x + t_y).select { |a| a != - Float::INFINITY && a != Float::INFINITY }
  t = all_t.size == 0 ? Float::INFINITY : all_t.min
  collision_pairs = []
  (t_x + t_y).each_with_index do |a_t, i| 
    if a_t == t
      collision_pairs << CollisionPair.new(particles[i % t_x.size], 
                                           i >= t_x.size ? :vertical : :horizontal)
    end
  end
  [t, collision_pairs]
end

def handle_collision(pair)
  # puts "antes #{pair.a.v_x ** 2 + pair.a.v_y ** 2 + pair.b.v_x ** 2 + pair.b.v_y ** 2}"
  if pair.b == :vertical
    pair.a.v_y *= -1
    # puts "vertical (#{pair.a.v_x}, #{pair.a.v_y})"
  elsif pair.b == :horizontal
    # puts "(#{pair.a.v_x}, #{pair.a.v_y})"
    pair.a.v_x *= -1   
    # puts "horiz (#{pair.a.v_x}, #{pair.a.v_y})"
  else # contra una party
    # puts "(#{pair.a.v_x}, #{pair.a.v_y}) (#{pair.b.v_x}, #{pair.b.v_y})"
    handle_particle_collision(CollisionPair.new(pair.a, pair.b))
    # puts "party (#{pair.a.v_x}, #{pair.a.v_y}) (#{pair.b.v_x}, #{pair.b.v_y})"
      # puts "despues #{pair.a.v_x ** 2 + pair.a.v_y ** 2 + pair.b.v_x ** 2 + pair.b.v_y ** 2}"
  end
end

def handle_particle_collision(pair)
  p = pair.a
  q = pair.b
  p.v_x += pair.jx / p.m
  p.v_y += pair.jy / p.m
  q.v_x -= pair.jx / q.m
  q.v_y -= pair.jy / q.m
end

def print_big_p(p)
  @show_big_p_file.write("#{p.x}\t#{p.y}\n")
end

def print_collision_t(collision_pairs, t)
  collision_pairs.each { |a| @show_t_file.write("#{t}\n") }
end

def print_v(particles, t)
  # @show_v_file.write("#{t}\n")
  # particles.each { |p| @show_v_file.write("#{p.v_x ** 2 + p.v_y ** 2}\n") }
  # @show_v_file.write("\n")
  # modules = particles.map { |p| Math.sqrt(p.v_x ** 2 + p.v_y ** 2) } 
  # sum = modules.reduce(0) { |a, e| a + e }
  # avg = sum / particles.size
  # var = modules.reduce(0) { |a, e| a + (avg - e) ** 2 }
  # @show_v_file.write("#{var}\n")
  particles.each{ |p| @show_v_file.write("#{p.v_x ** 2 + p.v_y ** 2}\n") }
end

def print(particles, file)
  file.write("#{particles.size + 2}\nx\ty\tr\tid\n")
  particles.each { |p| file.write("#{p.x}\t#{p.y}\t#{p.r}\t#{p.id}\n") }
  file.write("0\t0\t#{R1 / 10}\t0\n")
  file.write("#{L}\t#{L}\t#{R1 / 10}\t0\n")
end

def random_pos(r)
  Random.rand((0 + r)..(L - r))
end

def random_v(temp)
  Random.rand(V1_MIN..V1_MAX) * temp
end

def is_superposed(particle, others)
  others.any? { |p| ((p.x - particle.x) ** 2 + (p.y - particle.y) ** 2) < (p.r + particle.r) ** 2 }
end