# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- add `thinking_tokens` to the `complete_chat.ruby_llm` event payload. [#16](https://github.com/sinaptia/ruby_llm-instrumentation/pull/16) [@patriciomacadden](https://github.com/patriciomacadden)

## [0.2.1] - 2026-02-10

### Fixed

- `RubyLLM#paint` instrumentation was broken because it was calling `RubyLLM::Image#model`, which doesn't exist. [#13](https://github.com/sinaptia/ruby_llm-instrumentation/pull/13) [@patriciomacadden](https://github.com/patriciomacadden)

## [0.2.0] - 2026-01-20

### Added

- Custom metadata support via `RubyLLM::Instrumentation.with` block method. [#10](https://github.com/sinaptia/ruby_llm-instrumentation/pull/10) [@marckohlbrugge](https://github.com/marckohlbrugge)
