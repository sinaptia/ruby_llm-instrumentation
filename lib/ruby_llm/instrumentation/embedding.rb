module RubyLLM
  module Instrumentation
    module Embedding
      extend ActiveSupport::Concern

      included do
        class << self
          alias_method :original_embed, :embed
          def embed(text, model: nil, provider: nil, assume_model_exists: false, context: nil, dimensions: nil, tags: nil)
            raw_payload = {
              provider:,
              tags:
            }

            ActiveSupport::Notifications.instrument("embed_text.ruby_llm", raw_payload) do |payload|
              original_embed(text, model:, provider:, assume_model_exists:, context:, dimensions:).tap do |response|
                payload[:embedding] = response
                payload[:model] = response.model
                payload[:input_tokens] = response.input_tokens unless response.input_tokens.nil?

                # response.vectors is an array of floats, or an array of an array of floats
                payload[:vector_count] = response.vectors.first.is_a?(Array) ? response.vectors.size : 1
                payload[:dimensions] = response.vectors.first.is_a?(Array) ? response.vectors.map(&:size) : response.vectors.size
              end
            end
          end
        end
      end
    end
  end
end
