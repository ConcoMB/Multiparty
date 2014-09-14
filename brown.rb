
require 'debugger'
require_relative 'two_d_particle'
require_relative 'grid'
require_relative 'cell'
require_relative 'collision_pair'

L = 0.5
R1 = 0.005
M1 = 1
R2 = 0.05
M2 = 100
V1_MIN = -0.1
V1_MAX = 0.1
V2 = 0
DELTA_T = 0.25

def init(n)
  particles = [TwoDParticle.new(1, L / 2, L / 2, R2)] #the big one
  n.times do |i|
    p = nil
    loop do 
      p = TwoDParticle.new(i - 1, random_pos(R1), random_pos(R1), R1, random_v, random_v)
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
    t_c, collision_pairs = find_collisions(particles, collision_pairs)
    if t_c.nil?
      t = handle_movement(particles, DELTA_T, t, file)
    else
      while t_c > DELTA_T do 
        t = handle_movement(particles, DELTA_T, t, file)
        t_c -= DELTA_T
        puts "tc ahora es #{t_c}"
        return if t >= n 
      end
      t = handle_movement(particles, t_c, t)
      puts "ColisioN!"
      collision_pairs.each { |pair| handle_collision(pair) }
      t = handle_movement(particles, DELTA_T - t_c, t, file)
    end
    return if t >= n 
  end
end

def handle_movement(particles, t, t_acum, file = nil)
  particles.each { |p| p.move(t) }
  print(particles, file) if file != nil
  t_acum + t
end

def find_collisions(all_particles, pairs)
  particles = all_particles.select { |p|  pairs.none? { |pair| p == pair.a || p == pair.b } }
  # para q no choquen siempre las mismas
  return [nil, []] if particles.size == 0
  t_x = particles.map { |p| p.v_x > 0 ? (L - p.r - p.x) / p.v_x : (p.r - p.x) / p.v_x }
  t_y = particles.map { |p| p.v_y > 0 ? (L - p.r - p.y) / p.v_y : (p.r - p.y) / p.v_y }
  all_t = (t_x + t_y).select { |a| a != -Float::INFINITY && a != Float::INFINITY }
  t = all_t.min
  collision_pairs = []
  (t_x + t_y).each_with_index do |a_t, i| 
    if a_t == t 
      collision_pairs << CollisionPair.new(particles[i % t_x.size], i >= t_x.size ? :vertical : :horizontal)
    end
  end
  [t, collision_pairs]
end

def handle_collision(pair)
  # puts "old v (#{p.v_x}, #{p.v_y})"
  if pair.b == :vertical
    pair.a.v_y *= -1
  elsif pair.b == :horizontal
    pair.a.v_x *= -1   
  end
  # puts "new v (#{p.v_x}, #{p.v_y})"
end

def print(particles, file)
  file.write("#{particles.size + 4}\nx\ty\tr\n")
  particles.each { |p| file.write("#{p.x}\t#{p.y}\t#{p.r}\n") }
  file.write("0\t0\t#{R1 / 10}\n")
  file.write("0\t#{L}\t#{R1 / 10}\n")
  file.write("#{L}\t#{L}\t#{R1 / 10}\n")
  file.write("#{L}\t0\t#{R1 / 10}\n")
end

def random_pos(r)
  Random.rand((0 + r)..(L - r))
end

def random_v
  Random.rand(V1_MIN..V1_MAX)
end

def is_superposed(particle, others)
  others.any? { |p| ((p.x - particle.x) ** 2 + (p.y - particle.y) ** 2) < (p.r + particle.r) ** 2 }
end