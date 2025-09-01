require_relative 'vehicle'

class Car < Vehicle
  attr_reader :fuel_level

  def initialize(make, model)
    super
    @fuel_level = 100
  end

  def wheels
    4
  end

  def refuel
    @fuel_level = 100
  end
end
