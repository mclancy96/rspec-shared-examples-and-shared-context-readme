require_relative '../lib/boat'


RSpec.describe Boat do
  subject { Boat.new("Yamaha", "242X") }

  it_behaves_like "a vehicle that can start and stop"
  it_behaves_like "a wheeled vehicle", 0

  it "can be anchored" do
    expect(subject).not_to be_anchored
    subject.anchor
    expect(subject).to be_anchored
  end

  it "can be started and anchored independently" do
    subject.start
    subject.anchor
    expect(subject).to be_started
    expect(subject).to be_anchored
  end
end
