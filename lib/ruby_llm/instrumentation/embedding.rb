module RubyLLM
  module Instrumentation
    module Embedding
      extend ActiveSupport::Concern

      included do
        class << self
          alias_method :original_embed, :embed
          def embed(text, model: nil, provider: nil, assume_model_exists: false, context: nil, dimensions: nil)
            ActiveSupport::Notifications.instrument("embed_text.ruby_llm", { provider: }) do |payload|
              original_embed(text, model:, provider:, assume_model_exists:, context:, dimensions:).tap do |response|
                payload[:model] = response.model
                payload[:input_tokens] = response.input_tokens unless response.input_tokens.nil?

                # vectors can be a single vector or array of vectors
                vectors_array = response.vectors.is_a?(Array) ? response.vectors : [ response.vectors ]
                payload[:vector_count] = vectors_array.size

                first_vector = vectors_array.first
                if first_vector.respond_to?(:size)
                  payload[:dimensions] = first_vector.size
                elsif first_vector.is_a?(Numeric)
                  payload[:dimensions] = response.vectors.size
                end
              end
            end
          end
        end
      end
    end
  end
end
