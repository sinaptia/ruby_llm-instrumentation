module RubyLLM
  module Instrumentation
    module Moderation
      extend ActiveSupport::Concern

      included do
        class << self
          alias_method :original_moderate, :moderate
          def moderate(input, model: nil, provider: nil, assume_model_exists: false, context: nil)
            ActiveSupport::Notifications.instrument("moderate_text.ruby_llm", { provider: }) do |payload|
              original_moderate(input, model:, provider:, assume_model_exists:, context:).tap do |response|
                payload[:model] = response.model
                payload[:flagged] = response.flagged?
              end
            end
          end
        end
      end
    end
  end
end
