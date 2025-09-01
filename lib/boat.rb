require_relative 'vehicle'

class Boat < Vehicle
  def wheels
    0
  end

  def anchor
    @anchored = true
  end

  def anchored?
    !!@anchored
  end
end
