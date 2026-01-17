require "ruby_llm"
require "ruby_llm/instrumentation/version"
require "ruby_llm/instrumentation/railtie"

module RubyLLM
  module Instrumentation
    autoload :Chat, "ruby_llm/instrumentation/chat"
    autoload :Context, "ruby_llm/instrumentation/context"
    autoload :Embedding, "ruby_llm/instrumentation/embedding"
    autoload :Image, "ruby_llm/instrumentation/image"
    autoload :Transcription, "ruby_llm/instrumentation/transcription"
    autoload :Moderation, "ruby_llm/instrumentation/moderation"
  end
end

RubyLLM::Chat.include RubyLLM::Instrumentation::Chat
RubyLLM::Context.include RubyLLM::Instrumentation::Context
RubyLLM::Embedding.include RubyLLM::Instrumentation::Embedding
RubyLLM::Image.include RubyLLM::Instrumentation::Image
RubyLLM::Transcription.include RubyLLM::Instrumentation::Transcription
RubyLLM::Moderation.include RubyLLM::Instrumentation::Moderation
