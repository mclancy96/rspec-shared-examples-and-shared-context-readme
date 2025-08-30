# RSpec: Shared Examples & Shared Context: DRYing Up Your Specs

Welcome to Lesson 11! In this lesson, you'll learn how to reuse test logic across examples using RSpec's `shared_examples`, `shared_context`, `include_examples`, and `include_context`. We'll show you how these tools help you keep your specs DRY, readable, and maintainable—especially in larger apps. If you know Ruby and Rails but are new to automated testing, this is your guide to writing less code and getting more coverage!

---

## Why DRY Matters in Specs (And What Happens If You Don't)

As your app grows, you'll find yourself writing the same expectations or setup in multiple places. This leads to:

- Repetition (copy-paste code)
- Hard-to-maintain tests (if you need to change a rule, you have to update it everywhere)
- Bugs when you forget to update every copy
- Inconsistent tests (one place gets fixed, another doesn't)

**DRY (Don't Repeat Yourself)** is just as important in tests as in your app code!

### The Alternative: Copy-Paste Chaos

Suppose you have three models that all need to be soft deletable. Without shared examples, you might do this:

```ruby
# /spec/models/user_spec.rb
it "can be soft deleted" do
  user = create(:user)
  user.soft_delete!
  expect(user.deleted?).to be true
end

# /spec/models/post_spec.rb
it "can be soft deleted" do
  post = create(:post)
  post.soft_delete!
  expect(post.deleted?).to be true
end

# /spec/models/comment_spec.rb
it "can be soft deleted" do
  comment = create(:comment)
  comment.soft_delete!
  expect(comment.deleted?).to be true
end
```

If you ever change how soft deletion works, you have to update every copy. It's easy to miss one!

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

Shared examples let you define a set of tests once and include them in multiple places. This is perfect for shared behaviors (e.g., validations, soft deletion, permissions).

**How does it work?** Shared examples run expectations against the current `subject`. You can set `subject { ... }` in your spec to control what is being tested.

### Example 1: Soft Deletable

```ruby
# /spec/support/shared_examples/soft_deletable.rb
RSpec.shared_examples "soft deletable" do
  it "can be soft deleted" do
    subject.soft_delete!
    expect(subject.deleted?).to be true
  end
end
```

You can include these examples in any spec:

```ruby
# /spec/models/user_spec.rb
require 'rails_helper'
require 'support/shared_examples/soft_deletable'

RSpec.describe User, type: :model do
  subject { create(:user) } # This is what the shared example will test
  it_behaves_like "soft deletable"
end
```

**RSpec 5 Syntax Tip:** `it_behaves_like` and `include_examples` are interchangeable. Some teams prefer one for readability, but both do the same thing.

Or with `include_examples`:

```ruby
# /spec/models/post_spec.rb
require 'rails_helper'
require 'support/shared_examples/soft_deletable'

RSpec.describe Post, type: :model do
  subject { create(:post) }
  include_examples "soft deletable"
end
```

### Example 2: Validates Presence

```ruby
# /spec/support/shared_examples/validates_presence_of.rb
RSpec.shared_examples "validates presence of" do |field|
  it "is invalid without #{field}" do
    subject.send("#{field}=", nil)
    expect(subject).not_to be_valid
  end
end
```

```ruby
# /spec/models/user_spec.rb
it_behaves_like "validates presence of", :username
it_behaves_like "validates presence of", :email
```

### Example 3: API Error Handling

```ruby
# /spec/support/shared_examples/api_error_response.rb
RSpec.shared_examples "api error response" do |status|
  it "returns status #{status}" do
    expect(response).to have_http_status(status)
  end
  it "returns an error message" do
    expect(JSON.parse(response.body)["error"]).to be_present
  end
end
```

```ruby
# /spec/requests/users_spec.rb
include_examples "api error response", :not_found
```

---

## Shared Context: Reusing Setup

Shared context lets you share setup code (like `let`, `before`, or helper methods) across multiple specs. This is great for authentication, common data, or repeated setup.

### Example 1: Authenticated User

```ruby
# /spec/support/shared_contexts/authenticated_user.rb
RSpec.shared_context "authenticated user" do
  let(:user) { create(:user) }
  before { sign_in user }
end
```

You can include this context in any spec. Shared context adds variables, setup, or helper methods to the group—useful for authentication, sample data, or helpers.

```ruby
# /spec/requests/dashboard_spec.rb
require 'rails_helper'
require 'support/shared_contexts/authenticated_user'

RSpec.describe "Dashboard", type: :request do
  include_context "authenticated user"
  it "shows the dashboard" do
    get "/dashboard"
    expect(response).to have_http_status(:ok)
  end
end
```

### Example 2: Shared Data

```ruby
# /spec/support/shared_contexts/shared_data.rb
RSpec.shared_context "with sample data" do
  let!(:user) { create(:user) }
  let!(:post) { create(:post, user: user) }
end
```

```ruby
# /spec/requests/posts_spec.rb
include_context "with sample data"
it "shows the user's post" do
  get "/users/#{user.id}/posts"
  expect(response.body).to include(post.title)
end
```

### Example 3: Helper Methods

```ruby
# /spec/support/shared_contexts/json_helpers.rb
RSpec.shared_context "json helpers" do
  def json
    JSON.parse(response.body)
  end
end
```

```ruby
# /spec/requests/api_spec.rb
include_context "json helpers"
it "returns a JSON response" do
  get "/api/resource"
  expect(json["data"]).to be_present
end

# You can combine shared contexts for more realistic API specs:
include_context "authenticated user"
include_context "json helpers"
it "returns a JSON response for an authenticated user" do
  get "/api/protected_resource"
  expect(response).to have_http_status(:ok)
  expect(json["data"]).to be_present
end
```

---

## Passing Arguments to Shared Examples

You can make shared examples more flexible by passing arguments:

```ruby
# /spec/support/shared_examples/validates_presence_of.rb
RSpec.shared_examples "validates presence of" do |field|
  it "is invalid without #{field}" do
    subject.send("#{field}=", nil)
    expect(subject).not_to be_valid
  end
end
```

Use it like this:

```ruby
# /spec/models/user_spec.rb
it_behaves_like "validates presence of", :username
it_behaves_like "validates presence of", :email
```

---

## Best Practices for Shared Examples & Contexts

- Put shared examples and contexts in `/spec/support/` and require them in `rails_helper.rb`:

```ruby
# /spec/rails_helper.rb
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
```

- Name shared examples and contexts clearly ("soft deletable", "authenticated user", "validates presence of")
- Use shared examples for expectations, shared context for setup
- Don't overuse—only DRY up code that's repeated in 2+ places
- Keep shared code simple and focused—avoid making them too clever or generic
- Document what each shared example/context is for

**Anti-pattern:**

```ruby
# /spec/support/shared_examples/giant_shared_example.rb
RSpec.shared_examples "giant shared example" do
  # 100 lines of unrelated tests
end
```

*Don't make one shared example do too much!*

---

## Practice Prompts & Reflection Questions

Try these exercises to reinforce your learning:

1. Write a shared example for a common validation and use it in two model specs. How does it help if you later change the validation?
2. Write a shared context for a logged-in user and use it in a request spec. How does it help with repeated setup?
3. Refactor a spec file to use shared examples or contexts. How does it improve readability and maintainability?
4. Why is it important not to overuse shared examples/contexts? What could go wrong if you make them too generic?
5. Write a shared example that takes an argument and use it for multiple fields.
6. Write a shared context that provides helper methods for parsing JSON responses.

Reflect: What could go wrong if you copy-paste expectations or setup code everywhere? How would it affect your team's ability to refactor or add new features?

---

## What's Next?

Lab 4 is next! In Lab 4, you'll organize a larger Ruby class spec suite using contexts, subjects, and shared examples. This is your chance to put all these DRY techniques into practice on a real-world spec structure.

---

## Resources

- [RSpec: Shared Examples](https://relishapp.com/rspec/rspec-core/v/3-10/docs/example-groups/shared-examples)
- [RSpec: Shared Context](https://relishapp.com/rspec/rspec-core/v/3-10/docs/example-groups/shared-context)
- [Better Specs: DRY](https://www.betterspecs.org/#dry)
- [Thoughtbot: DRYing Up RSpec](https://thoughtbot.com/blog/drying-up-rspec)
