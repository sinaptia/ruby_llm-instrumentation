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
    assert event.payload[:chat].present?, "chat should be present"
    assert event.payload[:response].present?, "response should be present"
    assert_equal 11, event.payload[:input_tokens]
    assert_equal 16, event.payload[:output_tokens]
  end

  test "instruments chat completion with tags" do
    VCR.use_cassette("chat_complete") do
      chat = RubyLLM.chat(provider: "ollama", model: "gemma3", assume_model_exists: true)
      chat.tags = { user_id: 123, feature: "test_chat" }
      chat.ask("Say hello")
    end

    event = @events.first
    assert_equal({ user_id: 123, feature: "test_chat" }, event.payload[:tags])
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
    assert event.payload[:chat].present?, "chat should be present"
    assert event.payload[:response].present?, "response should be present"
  end

  test "instruments tool execution" do
    VCR.use_cassette("execute_tool") do
      RubyLLM.chat(provider: "ollama", model: "granite4", assume_model_exists: true).with_tool(WeatherTool).ask("What's the weather in La Plata, Argentina?")
    end

    event = @events.find { |e| e.name == "execute_tool.ruby_llm" }
    assert event.present?
    assert_equal "weather", event.payload[:tool_name]
    assert_equal({ "location" => "La Plata, Argentina" }, event.payload[:arguments])
    assert event.payload[:tool_call].present?, "tool_call should be present"
    assert event.payload[:chat].present?, "chat should be present"
    assert_equal false, event.payload[:halted]
  end

  test "instruments tool execution with tags" do
    VCR.use_cassette("execute_tool") do
      chat = RubyLLM.chat(provider: "ollama", model: "granite4", assume_model_exists: true)
      chat.tags = { user_id: 456, feature: "weather_lookup" }
      chat.with_tool(WeatherTool).ask("What's the weather in La Plata, Argentina?")
    end

    event = @events.find { |e| e.name == "execute_tool.ruby_llm" }
    assert_equal({ user_id: 456, feature: "weather_lookup" }, event.payload[:tags])
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
    assert event.payload[:embedding].present?, "embedding should be present"
    assert event.payload[:vector_count].positive?
    assert event.payload[:dimensions].present?, "dimensions should be present"
    assert event.payload[:dimensions].positive?, "dimensions should be positive"
  end

  test "instruments text embedding with tags" do
    VCR.use_cassette("embed_text") do
      RubyLLM.embed("Hello world", provider: "ollama", model: "nomic-embed-text", assume_model_exists: true, tags: { user_id: 789, feature: "search" })
    end

    event = @events.first
    assert_equal({ user_id: 789, feature: "search" }, event.payload[:tags])
  end

  test "instruments chat completion errors" do
    VCR.use_cassette("chat_complete_error") do
      assert_raises(StandardError) do
        RubyLLM.chat(provider: "ollama", model: "nonexistent-model").ask("Say hello")
      end
    end

    # Event should still be published even on error
    event = @events.find { |e| e.name == "complete_chat.ruby_llm" }
    assert event.present?
    assert_equal "ollama", event.payload[:provider]
    assert_equal "nonexistent-model", event.payload[:model]
    assert event.payload[:chat].present?, "chat should be present even on error"
  end

  test "has a version number" do
    assert RubyLLM::Instrumentation::VERSION
  end
end
