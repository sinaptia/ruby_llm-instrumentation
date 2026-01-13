module RubyLLM
  module Instrumentation
    module Chat
      extend ActiveSupport::Concern

      included do
        alias_method :original_complete, :complete
        def complete(&)
          raw_payload = {
            provider: @provider.slug,
            model: @model.id,
            streaming: block_given?
          }

          ActiveSupport::Notifications.instrument("complete_chat.ruby_llm", raw_payload) do |payload|
            original_complete(&).tap do |response|
              payload[:response] = response
              %i[input_tokens output_tokens cached_tokens cache_creation_tokens].each do |field|
                value = response.public_send(field)
                payload[field] = value unless value.nil?
              end
            end
          ensure
            payload[:chat] = self
          end
        end

        alias_method :original_execute_tool, :execute_tool
        def execute_tool(tool_call)
          raw_payload = {
            provider: @provider.slug,
            model: @model.id,
            tool_call: tool_call,
            tool_name: tool_call.name,
            arguments: tool_call.arguments
          }

          ActiveSupport::Notifications.instrument("execute_tool.ruby_llm", raw_payload) do |payload|
            original_execute_tool(tool_call).tap do |response|
              payload[:halted] = response.is_a?(Tool::Halt)
            end
          ensure
            payload[:chat] = self
          end
        end
      end
    end
  end
end
