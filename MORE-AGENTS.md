# Agents

- This is library in incubation period. It can break APIs, wildly change them, rename things. There should not be a restrain for progress.
- **When instructed to 'prepare a release', you must strictly execute the following steps:**
  1. **Bump the Version:** Increment the hotfix version number in the `pubspec.yaml` of the target package, unless a minor or major bump is explicitly requested.
  2. **Create the Changelog Header:** Add a new entry to the corresponding `CHANGELOG.md`. This entry **MUST explicitly include the new version number** matching `pubspec.yaml` (e.g., `## 1.0.1`). *CRITICAL: Failure to include the exact version number in the changelog header will cause the PubHub release checks to fail.*
  3. **Summarize Changes:** Group and summarize all changes made to the library since the last release under this new version header.
  4. **Continuous Documentation:** As a general rule, document every change in the changelog immediately as it happens. Do not wait for the release phase to write the changelog descriptions; simply finalize and version them during the release.
