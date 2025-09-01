require_relative '../lib/bike'


RSpec.describe Bike do
  subject { Bike.new("Trek", "FX 3") }

  it_behaves_like "a vehicle that can start and stop"
  it_behaves_like "a wheeled vehicle", 2

  it "does not have a fuel tank" do
    expect(subject).not_to respond_to(:fuel_level)
  end

  it "can be started and stopped multiple times" do
    3.times { subject.start; subject.stop }
    expect(subject).not_to be_started
  end
end
