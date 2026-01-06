module RubyLLM
  module Instrumentation
    module Transcription
      extend ActiveSupport::Concern

      included do
        class << self
          alias_method :original_transcribe, :transcribe
          def transcribe(audio_file, **kwargs)
            ActiveSupport::Notifications.instrument("transcribe_audio.ruby_llm", { provider: }) do |payload|
              original_transcribe(audio_file, **kwargs).tap do |response|
                payload[:model] = response.model
                %i[input_tokens output_tokens duration].each do |field|
                  value = result.public_send(field)
                  payload[field] = value unless value.nil?
                end
              end
            end
          end
        end
      end
    end
  end
end
