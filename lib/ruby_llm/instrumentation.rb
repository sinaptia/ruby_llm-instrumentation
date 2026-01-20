require "ruby_llm"
require "ruby_llm/instrumentation/version"
require "ruby_llm/instrumentation/railtie"

module RubyLLM
  module Instrumentation
    METADATA_KEY = :ruby_llm_instrumentation_metadata

    autoload :Chat, "ruby_llm/instrumentation/chat"
    autoload :Embedding, "ruby_llm/instrumentation/embedding"
    autoload :Image, "ruby_llm/instrumentation/image"
    autoload :Transcription, "ruby_llm/instrumentation/transcription"
    autoload :Moderation, "ruby_llm/instrumentation/moderation"

    class << self
      def with(metadata = {})
        previous_metadata = Thread.current[METADATA_KEY]
        Thread.current[METADATA_KEY] = (previous_metadata || {}).merge(metadata)
        yield
      ensure
        Thread.current[METADATA_KEY] = previous_metadata
      end

      def current_metadata
        Thread.current[METADATA_KEY] || {}
      end
    end
  end
end

RubyLLM::Chat.include RubyLLM::Instrumentation::Chat
RubyLLM::Embedding.include RubyLLM::Instrumentation::Embedding
RubyLLM::Image.include RubyLLM::Instrumentation::Image
RubyLLM::Transcription.include RubyLLM::Instrumentation::Transcription
RubyLLM::Moderation.include RubyLLM::Instrumentation::Moderation
