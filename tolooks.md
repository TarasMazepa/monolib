# ToLooks

- [ ] **1. Asynchronous Encoding Throughput Optimizations & Pre-Async Flush Validation Across Serializers**
  - **Idea**: Systematically maximize throughput, eliminate unneeded `Future` allocations on synchronous fast paths, and audit/validate deterministic pre-async flushes across all encoders (`jsonEncodeAsync`, `jsonlEncodeAsync`, `csvEncodeAsync`, `csvEncodeBatchAsync`, `jsonlEncodeBatchAsync`).
  - **Context**: In streaming pipelines, large collections are frequently serialized where the majority of rows, objects, or fields are already in memory and synchronous. Previous implementations awaited every element, allocating a `Future` per item and repeatedly context-switching across event loop turns. Additionally, when encoders buffer output in memory (via `BufferedStringSink`), failing to flush before an asynchronous pause (`await`) starves downstream consumers. We initiated a multi-phase optimization effort:
    - [x] Landed PR #336: Enhanced `iterateStreamOrIterable` to return a nullable `Future<void>?`, allowing synchronous collections to complete without allocating a `Future` or yielding to the event loop.
    - [x] Landed PR #337: Synchronous row fast path and pre-async flush in `csvEncodeAsync`.
    - [x] Landed: Write batching via `BufferedStringSink` in `jsonlEncodeAsync`.
    - [ ] In Review (PR #339): Synchronous fast path and comprehensive pre-async flush for primitives, maps, and iterables in `jsonEncodeAsync`.
  - **Investigation**:
    1. *Comprehensive Pre-Async Flush Audit across Encoders*:
       - **JSON (`jsonEncodeAsync`)**:
         - [x] Pre-async flush before awaiting nested `Future` values.
         - [x] Pre-async flush before awaiting `Future` map keys (`resumeMapFromKeyAsync`).
         - [x] Pre-async flush before awaiting `Future` map values (`resumeMapFromValueAsync`).
         - [x] Pre-async flush before awaiting child items when resuming `Iterable` traversal (`resumeIterableAsync`).
         - [x] Pre-async flush before awaiting incoming stream events in `Stream` arrays (`encodeStreamAsync`).
         - [x] Pre-async flush before awaiting `AsyncJsonWritable.writeJsonAsync`.
         - [x] Pre-async flush before awaiting async `toJson()` results.
       - **CSV (`csvEncodeAsync`, `csvEncodeBatchAsync`)**:
         - [x] Pre-async flush before awaiting row-level `Future`s (`rawRow is Future`, `toCsv() is Future`).
         - [x] Pre-async flush before awaiting cell-level `Future`s within a row (`writeRemainingCellsAsync`).
         - [x] Pre-async flush between stream events via `onStreamItemDone: activeSink.flush`.
         - [ ] Validate and audit `csvEncodeBatchAsync` to ensure chunk flushes propagate before batch boundary awaits.
       - **JSONL (`jsonlEncodeAsync`, `jsonlEncodeBatchAsync`)**:
         - [ ] Introduce synchronous fast path in `jsonlEncodeAsync` to avoid `(item) async` closure allocation per item when items and `jsonEncodeAsync` are synchronous.
         - [ ] Validate pre-async flush before awaiting `Future` items in `jsonlEncodeAsync`.
         - [ ] Validate pre-async flush before awaiting async `jsonEncodeAsync` execution.
         - [ ] Audit `jsonlEncodeBatchAsync` to guarantee batch flushes propagate before awaiting downstream sink operations.
    2. *Benchmark & Quantify*: Build benchmark suites comparing allocation counts, microtask queue depth, and throughput for purely synchronous collections, fully asynchronous streams, and mixed async payloads across all encoders.
    3. *Buffer Pooling & Sizing*: Investigate buffer reuse or adaptive sizing in `BufferedStringSink` to reduce heap allocations during multi-megabyte stream serialization.
    4. *Direct Byte Sink Integration*: Explore direct encoding into `ChunkedConversionSink<List<int>>` or `Utf8StreamStringSink` to avoid intermediate UTF-16 string allocations.

- [ ] **2. Convert Stale PRs (>3 Months) Using `pr-to-tolook` Skill**
  - **Idea**: Review and convert open pull requests older than 3 months into structured ToLooks in `tolooks.md` using the `pr-to-tolook` skill, then cleanly close the stale PRs after confirmation.
  - **Context**: As of 2026-11-14, 2 open PRs in `monolib` have been hanging for more than 3 months (created before 2026-08-14), adding noise to health audits and accumulating merge drift.
  - **Investigation**:
    - [ ] [#89](https://github.com/TarasMazepa/monolib/pull/89) [2026-07-23] *Feature/rich text* — inspect diff/comments, distill into a ToLook entry in `tolooks.md`, and close PR once captured.
    - [ ] [#73](https://github.com/TarasMazepa/monolib/pull/73) [2026-04-20] *feat: Add Custom Rich Text Prototype* — inspect diff/comments, distill into a ToLook entry in `tolooks.md`, and close PR once captured.

- [ ] **3. Migrate Non-Kebab-Case Markdown Files to `kebab-case`**
  - **Idea**: Rename remaining uppercase/underscore markdown files to pure `kebab-case` per `agents.md` and update any internal or workflow references to them.
  - **Context**: `repository-seed` standardized markdown naming to pure `kebab-case` (`agents.md`, `readme.md`, `tolooks.md`, `more-agents.md`). Root markdown files (`more-agents.md`, `readme.md`, `tolooks.md`) have been renamed; package-level `CHANGELOG.md` and `README.md` files were intentionally left as-is pending verification of `dart pub publish` / `PubHub` case-sensitivity requirements on Linux.
  - **Investigation**:
    - [x] Rename `MORE-AGENTS.md` → `more-agents.md` and update references
    - [x] Rename `README.md` → `readme.md` and update references
    - [x] Rename `TOLOOKS.md` → `tolooks.md` and update references
    - [ ] Check whether `dart pub publish --dry-run` / `PubHub` on Linux accepts lowercase `changelog.md` and `readme.md`
    - [ ] Rename `monolib-dart/CHANGELOG.md` → `monolib-dart/changelog.md` and update references
    - [ ] Rename `monolib-dart/README.md` → `monolib-dart/readme.md` and update references
    - [ ] Rename `monolib-flutter/CHANGELOG.md` → `monolib-flutter/changelog.md` and update references
    - [ ] Rename `monolib-flutter/README.md` → `monolib-flutter/readme.md` and update references
    - [ ] Rename `monolib-openrouter/CHANGELOG.md` → `monolib-openrouter/changelog.md` and update references
    - [ ] Rename `monolib-openrouter/README.md` → `monolib-openrouter/readme.md` and update references
