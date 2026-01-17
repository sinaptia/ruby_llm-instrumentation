module RubyLLM
  module Instrumentation
    module Context
      extend ActiveSupport::Concern

      included do
        def metadata
          @metadata ||= {}
        end
      end
    end
  end
end
