# Agents

- This is library in incubation period. It can break APIs, wildly change them, rename things. There should not be a restrain for progress.
- **When instructed to 'prepare a release', you must strictly execute the following steps:**
  1. **Bump the Version:** Increment the hotfix version number in the `pubspec.yaml` of the target package, unless a minor or major bump is explicitly requested.
  2. **Create the Changelog Header:** Add a new entry to the corresponding `CHANGELOG.md`. This entry **MUST explicitly include the new version number** matching `pubspec.yaml` (e.g., `## 1.0.1`). *CRITICAL: Failure to include the exact version number in the changelog header will cause the PubHub release checks to fail.*
  3. **Summarize Changes:** Group and summarize all changes made to the library since the last release under this new version header.
  4. **Continuous Documentation:** As a general rule, document every change in the changelog immediately as it happens. Do not wait for the release phase to write the changelog descriptions; simply finalize and version them during the release.

- **When instructed to onboard or create a new sublib (e.g., `monolib-new`), follow these steps:**
  1. **Initialize Package:** Create the new package directory and initialize it (e.g., `dart create -t package <name>`).
  2. **Standardize Structure:** Ensure it has the standard structure (`lib/`, `test/`, `pubspec.yaml`, `CHANGELOG.md`, `README.md`, `LICENSE`, `analysis_options.yaml` etc.).
  3. **Update CI:** Add the necessary `pub get`, `format`, `analyze`, and `test` steps for the new directory in `.github/workflows/ci.yml`.
  4. **Add Autotag Workflow:** Copy `.github/workflows/autotag-monolib-dart.yml` to `.github/workflows/autotag-<name>.yml` and replace occurrences of `monolib-dart` with `<name>` inside the trigger paths, job names, and script arguments.
  5. **Add Publish Workflow:** Copy `.github/workflows/publish-monolib-dart.yml` to `.github/workflows/publish-<name>.yml` and replace all occurrences of `monolib-dart` with `<name>` (in the tags, if condition, and working directories). Also correctly rename the GitHub Release title.
  6. *(Note: `manual-tag.yml` workflow accepts the directory name dynamically, so it does not need to be updated).*
