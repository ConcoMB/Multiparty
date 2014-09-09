require_relative 'particle'

def parse_particles(static_file, dynamic_file)
  # read particles
  dynamic_content = File.readlines(dynamic_file)
  static_content = File.readlines(static_file)
  particles = []
  dynamic_content.each_with_index do |line, i|
    next if i == 0
    pos = line.split(' ')
    particles << Particle.new(i, pos[0].to_f, pos[1].to_f)
  end
  # fill particles
  static_content.each_with_index do |line, i|
    case i.to_i
    when 0
      @n = line.to_i
      particles = particles[0..@n - 1]
    when 1
      @l = line.to_i 
    else
      pos = line.split(' ')
      particles[i - 2].r = pos[0].to_f
      particles[i - 2].color = pos[1].to_f
    end
  end
  [particles, @l, @n]
end