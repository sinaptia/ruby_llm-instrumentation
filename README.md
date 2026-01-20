# RubyLLM::Instrumentation

Rails instrumentation for RubyLLM.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "ruby_llm-instrumentation"
```

And then execute:

```bash
$ bundle
```

Now, RubyLLM will instrument all calls to your configured LLM.

## Usage

RubyLLM::Instrumentation uses ActiveSupport::Notifications to publish events. You can subscribe to these events to build custom monitoring, logging, or analytics.

### Subscribing to events

```ruby
# Subscribe to all LLM events
ActiveSupport::Notifications.subscribe(/ruby_llm/) do |name, start, finish, id, payload|
  duration = finish - start

  Rails.logger.info "LLM Call: #{payload[:provider]}/#{payload[:model]}"
  Rails.logger.info "Duration: #{duration}ms"
  Rails.logger.info "Input tokens: #{payload[:input_tokens]}"
  Rails.logger.info "Output tokens: #{payload[:output_tokens]}"
  Rails.logger.info "Metadata: #{payload[:metadata]}" if payload[:metadata]
end
```

### Metadata

You can attach custom metadata to any RubyLLM call for tracking, attribution, or analytics purposes. Metadata is included in the event payload under the `metadata` key.

```ruby
# Block form - great for controller around_actions
RubyLLM::Instrumentation.with(user_id: current_user.id, feature: "chat_assistant") do
  RubyLLM.chat.ask("Hello")
end

# One-liners work too
RubyLLM::Instrumentation.with(feature: "search") { RubyLLM.embed("text") }
```

The block form is particularly useful for setting request-level context:

```ruby
class ApplicationController < ActionController::Base
  around_action :instrument_llm_calls

  private

  def instrument_llm_calls
    RubyLLM::Instrumentation.with(user_id: current_user&.id, request_id: request.uuid) do
      yield
    end
  end
end
```

Nested blocks merge metadata, so you can set global context and add specific metadata per-call:

```ruby
RubyLLM::Instrumentation.with(user_id: 123) do
  RubyLLM::Instrumentation.with(feature: "chat") do
    RubyLLM.chat.ask("Hello")
    # metadata: { user_id: 123, feature: "chat" }
  end
end
```

## Available Events

### RubyLLM::Chat

#### complete_chat.ruby_llm

Triggered when `#ask` is called.

| Key                   | Value                                   |
| --------------------- | --------------------------------------- |
| provider              | Provider slug                           |
| model                 | Model ID                                |
| streaming             | Whether streaming was used              |
| chat                  | The chat, a RubyLLM::Chat object        |
| response              | The response, a RubyLLM::Message object |
| input_tokens          | Input tokens consumed                   |
| output_tokens         | Output tokens consumed                  |
| cached_tokens         | Cache reads tokens (if supported)       |
| cache_creation_tokens | Cache write tokens (if supported)       |
| metadata              | Custom metadata hash (if provided)      |

#### execute_tool.ruby_llm

Triggered when `#execute_tool` is called.

| Key       | Value                                               |
| --------- | --------------------------------------------------- |
| provider  | Provider slug                                       |
| model     | Model ID                                            |
| tool_call | The tool call, a RubyLLM::ToolCall object           |
| tool_name | The tool name                                       |
| arguments | The arguments                                       |
| chat      | The chat, a RubyLLM::Chat instance                  |
| halted    | Indicates if the tool stopped the conversation loop |
| metadata  | Custom metadata hash (if provided)                  |

### RubyLLM::Embedding

#### embed_text.ruby_llm

Triggered when `.embed` is called.

| Key          | Value                                                          |
| ------------ | -------------------------------------------------------------- |
| provider     | Provider slug                                                  |
| embedding    | The embedding, a RubyLLM::Embedding object                     |
| model        | Model ID                                                       |
| dimensions   | Number of embedding dimensions (or array of sizes if multiple) |
| input_tokens | Input tokens consumed                                          |
| vector_count | Number of vectors generated                                    |
| metadata     | Custom metadata hash (if provided)                             |

### RubyLLM::Image

#### paint_image.ruby_llm

Triggered when `.paint` is called.

| Key      | Value                                        |
| -------- | -------------------------------------------- |
| provider | Provider slug                                |
| size     | Image dimensions                             |
| image    | The image generated, a RubyLLM::Image object |
| model    | Model ID                                     |
| metadata | Custom metadata hash (if provided)           |

### RubyLLM::Moderation

#### moderate_text.ruby_llm

Triggered when `.moderate` is called.

| Key        | Value                                        |
| ---------- | -------------------------------------------- |
| provider   | Provider slug                                |
| moderation | The moderation, a RubyLLM::Moderation object |
| model      | Model ID                                     |
| flagged    | Whether the text was flagged                 |
| metadata   | Custom metadata hash (if provided)           |

### RubyLLM::Transcription

#### transcribe_audio.ruby_llm

Triggered when `.transcribe` is called.

| Key           | Value                                              |
| ------------- | -------------------------------------------------- |
| provider      | Provider slug                                      |
| transcription | The transcription, a RubyLLM::Transcription object |
| model         | Model ID                                           |
| input_tokens  | Input tokens consumed                              |
| output_tokens | Output tokens consumed                             |
| duration      | Audio duration in seconds (if available)           |
| metadata      | Custom metadata hash (if provided)                 |

## Contributing

You can open an issue or a PR in GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
