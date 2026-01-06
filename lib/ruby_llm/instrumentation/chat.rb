module RubyLLM
  module Instrumentation
    module Chat
      extend ActiveSupport::Concern

      included do
        alias_method :original_complete, :complete
        def complete(&)
          ActiveSupport::Notifications.instrument("complete_chat.ruby_llm", { provider: @provider.slug, model: @model.id, streaming: block_given? }) do |payload|
            original_complete(&).tap do |response|
              %i[input_tokens output_tokens cached_tokens cache_creation_tokens].each do |field|
                value = response.public_send(field)
                payload[field] = value unless value.nil?
              end
              payload[:tool_calls] = response.tool_calls&.size
            end
          end
        end

        alias_method :original_execute_tool, :execute_tool
        def execute_tool(tool_call)
          ActiveSupport::Notifications.instrument("execute_tool.ruby_llm", { provider: @provider.slug, model: @model.id, tool_name: tool_call.name, arguments: tool_call.arguments }) do |payload|
            original_execute_tool(tool_call).tap do |response|
              payload[:halted] = response.is_a?(Tool::Halt)
            end
          end
        end
      end
    end
  end
end
