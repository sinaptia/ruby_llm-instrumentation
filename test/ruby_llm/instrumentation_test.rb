require "test_helper"

class RubyLLM::InstrumentationTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert RubyLLM::Instrumentation::VERSION
  end
end
