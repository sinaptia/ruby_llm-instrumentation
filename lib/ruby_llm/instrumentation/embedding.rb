module RubyLLM
  module Instrumentation
    module Embedding
      extend ActiveSupport::Concern

      included do
        class << self
          alias_method :original_embed, :embed
          def embed(text, model: nil, provider: nil, assume_model_exists: false, context: nil, dimensions: nil)
            ActiveSupport::Notifications.instrument("embed_text.ruby_llm", { provider:, dimensions: }) do |payload|
              original_embed(text, model:, provider:, assume_model_exists:, context:, dimensions:).tap do |response|
                payload[:model] = response.model
                payload[:input_tokens] = response.input_tokens unless response.input_tokens.blank?
                payload[:vector_count] = response.vectors.is_a?(Array) ? response.vectors.size : 1
              end
            end
          end
        end
      end
    end
  end
end
