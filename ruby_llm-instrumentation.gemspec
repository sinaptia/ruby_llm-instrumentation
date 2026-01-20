require_relative "lib/ruby_llm/instrumentation/version"

Gem::Specification.new do |spec|
  spec.name        = "ruby_llm-instrumentation"
  spec.version     = RubyLLM::Instrumentation::VERSION
  spec.authors     = [ "Patricio Mac Adden" ]
  spec.email       = [ "patricio.macadden@sinaptia.dev" ]
  spec.homepage    = "https://github.com/sinaptia/ruby_llm-instrumentation"
  spec.summary     = "Rails instrumentation for RubyLLM"
  spec.description = "Rails instrumentation for RubyLLM"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.2.0"
  spec.add_dependency "ruby_llm"
end
