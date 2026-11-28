# Looked At

- [x] **Migrate Non-Kebab-Case Markdown Files to `kebab-case`**
  - **Status**: Root `MORE-AGENTS.md`, `README.md` and `TOLOOKS.md` were renamed to `more-agents.md`, `readme.md` and `tolooks.md`. Package-level `CHANGELOG.md` and `README.md` in `monolib-dart`, `monolib-flutter` and `monolib-openrouter` keep their uppercase names.
  - **Resolution**: Rejected for package files. With Dart SDK 3.14.1, `dart pub publish --dry-run` on `monolib-dart` exits `0` with uppercase names. With `readme.md` and `changelog.md` it reports 2 warnings ("Please consider renaming … to `README.md` / `CHANGELOG.md`", see https://dart.dev/tools/pub/publishing#important-files) and exits `65`. That would fail the `dart pub publish --dry-run` step of every `publish-*.yml` workflow. Pub-required files (`README.md`, `CHANGELOG.md`, `LICENSE`, `pubspec.yaml`, `analysis_options.yaml`) are an exception to the kebab-case rule.
