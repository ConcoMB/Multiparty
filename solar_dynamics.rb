
def calculate(planets, n, out_file)
  file = File.new(out_file, 'w')
  print(planets, file)
  file.close
end

def print(planets, file)
  file.write("#{planets.size + 2}\nm\tr\tx\ty\n1\t1\t#{-Planet::INIT_MAX_DISTANCE * 2}\t#{-Planet::INIT_MAX_DISTANCE * 2}\n1\t1\t#{Planet::INIT_MAX_DISTANCE * 2}\t#{Planet::INIT_MAX_DISTANCE * 2}\n")
  planets.each {|p| file.write("#{p.m}\t#{p.r}\t#{p.x}\t#{p.y}\n") } 
end