# frozen_string_literal: true

require "uri/idna"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec.shared_examples "valid" do |input|
  it "does not raise an error for '#{input}'" do
    expect { described_class.call(input) }.not_to raise_error
  end
end

RSpec.shared_examples "invalid" do |input|
  it "raises an error for '#{input}'" do
    expect { described_class.call(input) }.to raise_error(URI::IDNA::Error)
  end
end
