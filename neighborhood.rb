require_relative 'grid'

def find_neighbors(particles, particle_id, r, m, l, brute_force = false, border = false, out_file = nil)
  if brute_force
    # puts 'brute force'
    t1 = Time.now
    if particle_id.nil?
      neighbors = particles.map { |p| find_neighbors_brute(particles, particles[p.id - 1], r, border) }
    else
      neighbors = find_neighbors_brute(particles, particles[particle_id - 1], r, border) 
    end
  else
    # puts 'grid'
    if m
      m = m.to_i
      unless m_is_valid?(m, @l, r)
        puts "M is too big, must be less or equal to #{infer_m(@l, r)}"
        return nil
      end
    else 
      m = infer_m(@l, r)
      puts "inferred M -> #{m}"
    end
    grid = Grid.new(m, @l)
    particles.each do |p|
      grid.add(p)
    end
    t1 = Time.now
    if particle_id.nil?
      neighbors = particles.map { |p| find_neighbors_grid(grid, particles[p.id - 1], r, border) }
    else
      neighbors = find_neighbors_grid(grid, particles[particle_id - 1], r, border)
    end
  end
  if particle_id.nil?
    # neighbors.each_with_index { |p, i| puts "#{i + 1}: #{p.map{ |n| n.id }.join(', ')}" }
  else
    neighbors.sort!{ |a, b| a.id <=> b.id }
    # neighbors.each { |p| puts "#{p.id == particle_id ? '*' : ' '}#{p}" }
    generate_output_file(particles, neighbors, particles[p_id - 1], out_file) if out_file
  end
  # puts '======'
  # puts "Total time elapsed: #{(Time.now - t0)} ms"
  # puts "Neighbor finding time: #{(t2 - t1)} ms"
  neighbors
end

private

def find_neighbors_brute(particles, particle, r, border)
  particles.select do |e| 
    delta_x = (e.x - particle.x).abs
    delta_y = (e.y - particle.y).abs
    if border
      delta_x = @l - delta_x if delta_x > @l / 2 
      delta_y = @l - delta_y if delta_y > @l / 2 
    end  
    e != particle && (Math.sqrt(delta_x ** 2 + delta_y ** 2) - (e.r + particle.r)) < r
  end
end

def find_neighbors_grid(grid, particle, r, border)
  coords = grid.particle_coords(particle)
  i = coords[:x]
  j = coords[:y]
  neighbors = []
  (-1..1).each do |d_i|
    (-1..1).each do |d_j|
      if border
        neighbors += find_neighbors_brute(grid.grid[(i + d_i) % grid.m][(j + d_j) % grid.m].particles, particle, r, border)
      else
        next unless valid_cell(i + d_i, j + d_j, 0, grid.m)
        # puts "cell #{i + d_i} #{j + d_j}, #{grid.grid[i + d_i][j + d_j].particles.size} particles"
        neighbors += find_neighbors_brute(grid.grid[i + d_i][j + d_j].particles, particle, r, border)
      end
    end  
  end
  neighbors.delete(particle)
  neighbors
end

def valid_cell(i, j, min, max)
  i >= min && j >= min && i < max && j < max
end

def generate_output_file(particles, neighbors, particle, file)
  file = File.open(file, 'w') 
  file.write("#{particles.size}\ncolor\tx\ty\n")
  particles.each do |p|
    color = p == particle ? 2 : (neighbors.include?(p) ? 1 : 0)
    file.write("#{color}\t#{p.x}\t#{p.y}\n") 
  end
  file.close
end

def m_is_valid?(m, l, r)
  !((l.to_f / r).floor < m)
end

def infer_m(l, r)
  (l.to_f / r).floor
end