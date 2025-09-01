# spec/spec_helper.rb

# Load all support files (shared examples, contexts, etc.)
Dir[File.join(__dir__, 'support', '**', '*.rb')].sort.each { |f| require f }
RSpec.configure do |config|
  # config.example_status_persistence_file_path = "spec/examples.txt"
end
