class Vehicle
  attr_reader :make, :model, :started

  def initialize(make, model)
    @make = make
    @model = model
    @started = false
  end

  def start
    @started = true
  end

  def stop
    @started = false
  end

  def started?
    @started
  end
end
