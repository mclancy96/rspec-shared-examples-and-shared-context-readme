# RSpec: Shared Examples & Shared Context: DRYing Up Your Specs

In this lesson, you'll learn how to reuse test logic across examples using RSpec's `shared_examples`, `shared_context`, `include_examples`, and `include_context`. We'll show you how these tools help you keep your specs DRY, readable, and maintainable—especially in larger apps. If you know Ruby and Rails but are new to automated testing, this is your guide to writing less code and getting more coverage!

---

## Why DRY Matters in Specs (And What Happens If You Don't)

As your app grows, you'll find yourself writing the same expectations or setup in multiple places. This leads to:

- Repetition (copy-paste code)
- Hard-to-maintain tests (if you need to change a rule, you have to update it everywhere)
- Bugs when you forget to update every copy
- Inconsistent tests (one place gets fixed, another doesn't)

**DRY (Don't Repeat Yourself)** is just as important in tests as in your app code!

### The Alternative: Copy-Paste Chaos

Suppose you have three vehicle classes that all need to be able to start and stop. Without shared examples, you might do this:

```ruby
# /spec/car_spec.rb
it "can start and stop" do
  car = Car.new("Toyota", "Corolla")
  car.start
  expect(car).to be_started
  car.stop
  expect(car).not_to be_started
end

# /spec/bike_spec.rb
it "can start and stop" do
  bike = Bike.new("Trek", "FX 3")
  bike.start
  expect(bike).to be_started
  bike.stop
  expect(bike).not_to be_started
end

# /spec/boat_spec.rb
it "can start and stop" do
  boat = Boat.new("Yamaha", "242X")
  boat.start
  expect(boat).to be_started
  boat.stop
  expect(boat).not_to be_started
end
```

If you ever change how starting/stopping works, you have to update every copy. It's easy to miss one!

---

## Shared Examples vs Shared Context: What's the Difference?

Here's a quick comparison to help you remember:

| Feature            | shared_examples                | shared_context                  |
|--------------------|-------------------------------|---------------------------------|
| Purpose            | Reuse expectations/tests      | Reuse setup (let, before, etc.) |
| Typical Usage      | it_behaves_like, include_examples | include_context              |
| Operates On        | The current `subject`         | Adds variables/methods to group  |
| Example            | Validations, permissions      | Auth, sample data, helpers       |

**Tip:** Use shared examples for repeated tests, and shared context for repeated setup.

Shared examples let you define a set of tests once and include them in multiple places. This is perfect for shared behaviors (e.g., starting/stopping, wheel count, etc.).

**How does it work?** Shared examples run expectations against the current `subject`. You can set `subject { ... }` in your spec to control what is being tested.

### Example 1: Startable Vehicle

```ruby
# /spec/shared_examples_spec.rb
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
```

You can include these examples in any spec:

```ruby
# /spec/car_spec.rb
require 'car'
require_relative 'shared_examples_spec'

RSpec.describe Car do
  subject { Car.new("Toyota", "Corolla") }
  it_behaves_like "a vehicle that can start and stop"
end
```

Or with `include_examples`:

```ruby
# /spec/bike_spec.rb
require 'bike'
require_relative 'shared_examples_spec'

RSpec.describe Bike do
  subject { Bike.new("Trek", "FX 3") }
  include_examples "a vehicle that can start and stop"
end
```

### Example 2: Wheeled Vehicle (with arguments)

```ruby
# /spec/shared_examples_spec.rb
RSpec.shared_examples "a wheeled vehicle" do |expected_wheels|
  it "has the correct number of wheels" do
    expect(subject.wheels).to eq(expected_wheels)
  end
end
```

```ruby
# /spec/car_spec.rb
it_behaves_like "a wheeled vehicle", 4
# /spec/bike_spec.rb
it_behaves_like "a wheeled vehicle", 2
# /spec/boat_spec.rb
it_behaves_like "a wheeled vehicle", 0
```

---

---

## Shared Context: Reusing Setup

Shared context lets you share setup code (like `let`, `before`, or helper methods) across multiple specs. This is great for repeated setup, like starting a vehicle or setting a full tank.

### Example 1: With a Started Vehicle

```ruby
# /spec/shared_examples_spec.rb
RSpec.shared_context "with a started vehicle" do
  before { subject.start }
end
```

You can include this context in any spec. Shared context adds setup or helper methods to the group.

```ruby
# /spec/car_spec.rb
include_context "with a started vehicle"
it "is started" do
  expect(subject).to be_started
end
```

---

---

## Passing Arguments to Shared Examples

You can make shared examples more flexible by passing arguments. For example, our wheeled vehicle shared example takes the expected number of wheels:

```ruby
# /spec/shared_examples_spec.rb
RSpec.shared_examples "a wheeled vehicle" do |expected_wheels|
  it "has the correct number of wheels" do
    expect(subject.wheels).to eq(expected_wheels)
  end
end
```

Use it like this:

```ruby
# /spec/car_spec.rb
it_behaves_like "a wheeled vehicle", 4
# /spec/bike_spec.rb
it_behaves_like "a wheeled vehicle", 2
# /spec/boat_spec.rb
it_behaves_like "a wheeled vehicle", 0
```

---

## Best Practices for Shared Examples & Contexts

- Put shared examples and contexts in a dedicated file (like `/spec/shared_examples_spec.rb`) and require or load them in your spec files as needed.
- Name shared examples and contexts clearly (e.g., "a vehicle that can start and stop", "a wheeled vehicle", "with a started vehicle").
- Use shared examples for expectations, shared context for setup.
- Don't overuse—only DRY up code that's repeated in 2+ places.
- Keep shared code simple and focused—avoid making them too clever or generic.
- Document what each shared example/context is for.

**Anti-pattern:**

```ruby
# /spec/shared_examples_spec.rb
RSpec.shared_examples "giant shared example" do
  # 100 lines of unrelated vehicle tests
end
```

*Don't make one shared example do too much!*

---

## Getting Hands-On

Ready to practice? Here’s how to get started:

1. **Fork and clone this repo to your own GitHub account.**
2. **Install dependencies:**

    ```zsh
    bundle install
    ```

3. **Run the specs:**

    ```zsh
    bin/rspec
    ```

4. **Explore the code:**

   - All lesson code uses the Vehicles domain (see `lib/` and `spec/`).
   - Review the examples for shared_examples and shared_context in `spec/shared_examples_spec.rb`, `spec/car_spec.rb`, `spec/bike_spec.rb`, and `spec/boat_spec.rb`.

5. **Implement the pending specs:**

   - Open `spec/car_spec.rb` and look for specs marked as `pending`.
   - Implement the real methods in the vehicle classes (`lib/car.rb`, etc.) as needed so the pending specs pass.

6. **Re-run the specs** to verify your changes!

**Challenge:** Try writing your own shared example or shared context for a new vehicle feature (e.g., "a vehicle that can honk" or "with a flat tire") and use it in multiple specs.

---

## What's Next?

Lab 4 is next! In Lab 4, you'll organize a larger Ruby class spec suite using contexts, subjects, and shared examples. This is your chance to put all these DRY techniques into practice on a real-world spec structure.

---

## Resources

- [RSpec: Shared Examples](https://relishapp.com/rspec/rspec-core/v/3-10/docs/example-groups/shared-examples)
- [RSpec: Shared Context](https://relishapp.com/rspec/rspec-core/v/3-10/docs/example-groups/shared-context)
- [Better Specs: DRY](https://www.betterspecs.org/#dry)
- [Thoughtbot: DRYing Up RSpec](https://thoughtbot.com/blog/drying-up-rspec)
