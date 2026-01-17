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

RubyLLM::Instrumentation uses ActiveSupport::Notifications to publish events. You can subscribe to these events to build custom monitoring, logging, or analytics:

```ruby
# Subscribe to all LLM events
ActiveSupport::Notifications.subscribe(/ruby_llm/) do |name, start, finish, id, payload|
  duration = finish - start

  Rails.logger.info "LLM Call: #{payload[:provider]}/#{payload[:model]}"
  Rails.logger.info "Duration: #{duration}ms"
  Rails.logger.info "Input tokens: #{payload[:input_tokens]}"
  Rails.logger.info "Output tokens: #{payload[:output_tokens]}"
end
```

## Custom Metadata

You can attach custom metadata to LLM calls using `RubyLLM::Context`. This is useful for tracking user IDs, tenant information, request IDs, or any other contextual data in your instrumentation events:

```ruby
# Create a context and add metadata
context = RubyLLM::Context.new(RubyLLM.config)
context.metadata[:user_id] = current_user.id
context.metadata[:tenant] = current_tenant.slug
context.metadata[:request_id] = request.uuid

# Use the context with your chat
chat = RubyLLM.chat(model: "gpt-4")
chat.with_context(context)
chat.ask("Hello!")

# Access metadata in your event subscribers
ActiveSupport::Notifications.subscribe(/ruby_llm/) do |name, start, finish, id, payload|
  if payload[:metadata].present?
    Rails.logger.info "User ID: #{payload[:metadata][:user_id]}"
    Rails.logger.info "Tenant: #{payload[:metadata][:tenant]}"
  end
end
```

The `metadata` field is included in all instrumentation events when a context is present.

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
| metadata              | Custom metadata hash (if context used)  |

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
| metadata  | Custom metadata hash (if context used)              |

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
| metadata     | Custom metadata hash (if context used)                         |

### RubyLLM::Image

#### paint_image.ruby_llm

Triggered when `.paint` is called.

| Key      | Value                                        |
| -------- | -------------------------------------------- |
| provider | Provider slug                                |
| size     | Image dimensions                             |
| image    | The inage generated, a RubyLLM::Image object |
| model    | Model ID                                     |
| metadata | Custom metadata hash (if context used)       |

### RubyLLM::Moderation

#### moderate_text.ruby_llm

Triggered when `.moderate` is called.

| Key        | Value                                        |
| ---------- | -------------------------------------------- |
| provider   | Provider slug                                |
| moderation | The moderation, a RubyLLM::Moderation object |
| model      | Model ID                                     |
| flagged    | Whether the text was flagged                 |
| metadata   | Custom metadata hash (if context used)       |

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
| metadata      | Custom metadata hash (if context used)             |

## Contributing

You can open an issue or a PR in GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
