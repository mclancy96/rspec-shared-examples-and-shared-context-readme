# Shared examples and shared context for vehicles
RSpec.shared_examples "a vehicle that can start and stop" do
  it "can start" do
    subject.start
    expect(subject).to be_started
  end

  it "can stop" do
    subject.start
    subject.stop
    expect(subject).not_to be_started
  end
end

RSpec.shared_examples "a wheeled vehicle" do |expected_wheels|
  it "has the correct number of wheels" do
    expect(subject.wheels).to eq(expected_wheels)
  end
end

RSpec.shared_context "with a started vehicle" do
  before { subject.start }
end
