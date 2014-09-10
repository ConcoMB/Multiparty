class Cell

  attr_accessor :particles

  def initialize
    @particles = []
  end

  def add(particle)
    @particles << particle
  end

  def to_s
    @particles.to_s
  end

end