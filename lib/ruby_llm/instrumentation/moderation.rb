module RubyLLM
  module Instrumentation
    module Moderation
      extend ActiveSupport::Concern

      included do
        class << self
          alias_method :original_moderate, :moderate
          def moderate(input, model: nil, provider: nil, assume_model_exists: false, context: nil)
            raw_payload = {
              provider:
            }

            ActiveSupport::Notifications.instrument("moderate_text.ruby_llm", raw_payload) do |payload|
              original_moderate(input, model:, provider:, assume_model_exists:, context:).tap do |response|
                payload[:moderation] = response
                payload[:model] = response.model
                payload[:flagged] = response.flagged?
                payload[:metadata] = context.metadata if context
              end
            end
          end
        end
      end
    end
  end
end
