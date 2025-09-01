require_relative '../lib/car'


RSpec.describe Car do
  subject { Car.new("Toyota", "Corolla") }

  it_behaves_like "a vehicle that can start and stop"
  it_behaves_like "a wheeled vehicle", 4

  describe "fuel" do
    include_context "with a started vehicle"

    it "has a full tank when initialized" do
      expect(subject.fuel_level).to eq(100)
    end

    it "can be refueled" do
      subject.instance_variable_set(:@fuel_level, 20)
      subject.refuel
      expect(subject.fuel_level).to eq(100)
    end
  end

  pending "can drive a certain distance and reduce fuel" # for students
  pending "warns when fuel is low" # for students
end
