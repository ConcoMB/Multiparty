
require 'byebug'
require_relative 'harmonic_oscilator_particle'

DELTA_T = 0.01

DELTA_T_2 = DELTA_T ** 2

DELTA_ORDER_2 = DELTA_T ** 2 / 2
DELTA_ORDER_3 = DELTA_T ** 3 / 6
DELTA_ORDER_4 = DELTA_T ** 4 / 24
DELTA_ORDER_5 = DELTA_T ** 5 / 120

# ALPHA_0 = 19.0 / 90
# ALPHA_1 = 3.0 / 16
ALPHA_0 = 0
ALPHA_1 = 1


def calculate(method, n, file_name)
  file = file_name ? File.open(file_name, 'w') : nil 
  particle_old = HarmonicOscilatorParticle.new
  particle_current = do_particle(particle_old, 'euler') 
  particle_current.init_r if method == 'gear'
  particle_new = nil
  print(particle_old, file)
  print(particle_current, file)
  t = DELTA_T * 2
  while t < n do
    particle_new = do_particle(particle_current, method, particle_old, t)
    print(particle_new, file)
    particle_old = particle_current
    particle_current = particle_new
    particle_new = nil
    t += DELTA_T
  end
  file.close if file
end

def do_particle(p, method, old_p = nil, t = nil)
  case method
  when 'verlet'
    r = 2 * p.r - old_p.r + DELTA_T_2 / p.m * p.f 
    v = r - old_p.r / (2 * DELTA_T)
    return HarmonicOscilatorParticle.new(r, v)
  when 'leap'
    v = p.v + DELTA_T * p.f / p.m
    r = p.r + DELTA_T * v
    return HarmonicOscilatorParticle.new(r, v)
  when 'velocity'
    r = p.r + DELTA_T * p.v + DELTA_T_2 * p.f / p.m
    p_aux = HarmonicOscilatorParticle.new(r, p.v)
    v = p.v + DELTA_T / (2 * p.m) * (p.f + p_aux.f) 
    return HarmonicOscilatorParticle.new(r, v)
  when 'beeman'
    r = p.r + p.v * DELTA_T + 1.0 / 6 * (4 * p.a - old_p.a) * DELTA_T_2
    part = HarmonicOscilatorParticle.new(r, p.v)
    v = p.v + 1.0 / 6 * (2 * part.a + 5 * p.a - old_p.a) * DELTA_T
    return HarmonicOscilatorParticle.new(r, v)
  when 'euler'
    r = p.r + DELTA_T * p.v + DELTA_T_2 / (2 * p.m) * p.f
    v = p.v + DELTA_T / p.m * p.f
    return HarmonicOscilatorParticle.new(r, v)
  when 'gear'
    return compute_gear(p)
  when 'exact'
    return HarmonicOscilatorParticle.new(p.exact_r(t), p.v)
  end
end 

def compute_gear(p)
  r = p.r + p.r1 * DELTA_T + p.r2 * DELTA_ORDER_2 + p.r3 * DELTA_ORDER_3 + p.r4 * DELTA_ORDER_4 + p.r5 * DELTA_ORDER_5
  r1 = p.r1 + p.r2 * DELTA_T + p.r3 * DELTA_ORDER_2 + p.r4 * DELTA_ORDER_3 + p.r5 * DELTA_ORDER_4
  r2 = p.r2 + p.r3 * DELTA_T + p.r4 * DELTA_ORDER_2 + p.r5 * DELTA_ORDER_3
  r3 = p.r3 + p.r4 * DELTA_T + p.r5 * DELTA_ORDER_2
  r4 = p.r4 + p.r5 * DELTA_T
  r5 = p.r5
  temp_p = HarmonicOscilatorParticle.new(r, r1)
  delta_r2 = (temp_p.a - r2) * DELTA_ORDER_2
  rc = r + ALPHA_0 * delta_r2
  r1c = r1 + ALPHA_1 * delta_r2 
  HarmonicOscilatorParticle.new(rc, r1c)
end

def print(p, file)
  if file 
    file.write("#{p.r}\n") 
  else
    puts "#{p.r}"
  end
end
