require "test_helper"

class RubyLLM::InstrumentationTest < ActiveSupport::TestCase
  setup do
    @events = []
    @subscription = ActiveSupport::Notifications.subscribe(/\.ruby_llm$/) do |*args|
      @events << ActiveSupport::Notifications::Event.new(*args)
    end
  end

  teardown do
    ActiveSupport::Notifications.unsubscribe(@subscription)
  end

  test "instruments chat completion" do
    VCR.use_cassette("chat_complete") do
      RubyLLM.chat(provider: "ollama", model: "gemma3", assume_model_exists: true).ask("Say hello")
    end

    assert_equal 1, @events.size
    event = @events.first
    assert_equal "complete_chat.ruby_llm", event.name
    assert_equal "ollama", event.payload[:provider]
    assert_equal "gemma3", event.payload[:model]
    assert_equal false, event.payload[:streaming]
    assert_equal 11, event.payload[:input_tokens]
    assert_equal 16, event.payload[:output_tokens]
  end

  test "instruments chat completion with streaming" do
    chunks = []

    VCR.use_cassette("chat_complete_with_streaming") do
      RubyLLM.chat(provider: "ollama", model: "gemma3", assume_model_exists: true).ask("Say hello") { |chunk| chunks << chunk }
    end

    assert chunks.any?
    assert_equal 1, @events.size
    event = @events.first
    assert_equal "complete_chat.ruby_llm", event.name
    assert_equal true, event.payload[:streaming]
  end

  test "instruments tool execution" do
    VCR.use_cassette("execute_tool") do
      RubyLLM.chat(provider: "ollama", model: "granite4", assume_model_exists: true).with_tool(WeatherTool).ask("What's the weather in La Plata, Argentina?")
    end

    event = @events.find { |e| e.name == "execute_tool.ruby_llm" }
    assert event.present?
    assert_equal "weather", event.payload[:tool_name]
    assert_equal({ "location" => "La Plata, Argentina" }, event.payload[:arguments])
    assert_equal false, event.payload[:halted]
  end

  test "instruments text embedding" do
    VCR.use_cassette("embed_text") do
      RubyLLM.embed("Hello world", provider: "ollama", model: "nomic-embed-text", assume_model_exists: true)
    end

    assert_equal 1, @events.size
    event = @events.first
    assert_equal "embed_text.ruby_llm", event.name
    assert_equal "ollama", event.payload[:provider]
    assert_equal "nomic-embed-text", event.payload[:model]
    assert event.payload[:vector_count].positive?
  end

  test "has a version number" do
    assert RubyLLM::Instrumentation::VERSION
  end
end
