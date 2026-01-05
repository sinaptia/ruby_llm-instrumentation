module RubyLLM
  module Instrumentation
    class Railtie < ::Rails::Railtie
      INFLECTION_OVERRIDES = { "ruby_llm" => "RubyLLM" }.freeze

      initializer "ruby_llm_instrumentation.inflector", after: "ruby_llm.inflections", before: :set_autoload_paths do
        ActiveSupport::Inflector.inflections(:en) do |inflections|
          # The RubyLLM gem registers "RubyLLM" as an acronym in its railtie,
          # which breaks underscore conversion (RubyLLM.underscore => "rubyllm").
          # We need to remove it and use "LLM" as an acronym instead for proper conversion:
          # * "ruby_llm".camelize => "RubyLLM" (not "RubyLlm")
          # * "RubyLLM".underscore => "ruby_llm" (not "rubyllm")
          inflections.acronyms.delete("rubyllm")
          inflections.acronym("LLM")
        end

        Rails.autoloaders.each do |loader|
          loader.inflector.inflect(INFLECTION_OVERRIDES)
        end
      end
    end
  end
end
