module RubyLLM
  module Instrumentation
    module Image
      extend ActiveSupport::Concern

      included do
        class << self
          alias_method :original_paint, :paint
          def paint(prompt, model: nil, provider: nil, assume_model_exists: false, size: "1024x1024", context: nil)
            ActiveSupport::Notifications.instrument("paint_image.ruby_llm", { provider:, size: }) do |payload|
              original_paint(prompt, model:, provider:, assume_model_exists:, size:, context:).tap do |response|
                payload[:model] = response.model
              end
            end
          end
        end
      end
    end
  end
end
