import 'dart:io';

void main() {
  final Stopwatch stopwatch = Stopwatch()..start();
  final Directory repoRoot = findRepoRoot();
  print('Monolib repository root: ${repoRoot.path}');

  final buffer = StringBuffer();

  buffer.writeln('# Monolib — Complete API Reference & Documentation');
  buffer.writeln();
  buffer.writeln(
      '> Single-file source of truth for all public APIs across `monolib_dart`, `monolib_flutter`, and `monolib_openrouter`.');
  buffer.writeln(
      '> Auto-generated from exported library declarations and Dartdoc comments.');
  buffer.writeln();

  final List<PackageSpec> packages = [
    PackageSpec(
      name: 'monolib_dart',
      directoryName: 'monolib-dart',
      description:
          'General-purpose utilities, streaming codecs (CSV, JSONL), async JSON, Pillar DI/state management, CLI parsing, Zalgo, and extensions.',
      barrels: [
        BarrelSpec(
            'pillar.dart', 'Pillar — Dependency Injection & State Management'),
        BarrelSpec('fluent_json.dart',
            'FluentJson — Dynamic JSON Navigation & Unboxing'),
        BarrelSpec('json_encode_async.dart',
            'Async JSON — Non-blocking Streaming JSON Serialization'),
        BarrelSpec('stream.dart',
            'Reactive Streams — Stream/Sink Extensions & Composite Event Sinks'),
        BarrelSpec(
            'csv.dart', 'CSV — Streaming CSV Encoders, Decoders & Batchers'),
        BarrelSpec('jsonl.dart',
            'JSONL — Streaming JSON Lines Encoders, Decoders & Batchers'),
        BarrelSpec('cli.dart', 'CLI — Command-Line Flag Parser'),
        BarrelSpec(
            'io.dart', 'I/O — File System, I/O Sinks & Batch JSONL Writers'),
        BarrelSpec('zalgo.dart', 'Zalgo — Zalgo Text Encoding & Decoding'),
        BarrelSpec('monolib_dart.dart',
            'Core Utilities — Extensions, Data Structures & Tables'),
      ],
    ),
    PackageSpec(
      name: 'monolib_flutter',
      directoryName: 'monolib-flutter',
      description:
          'Flutter widgets, extensions, Pillar ChangeNotifier adapters, and Zalgo text utilities.',
      barrels: [
        BarrelSpec('monolib_flutter.dart',
            'Flutter Utilities — Widgets, Context/Scroll Extensions & Pillar Listenable'),
        BarrelSpec('zalgo.dart',
            'Flutter Zalgo — Text Range Mapping for Flutter Text Editing'),
      ],
    ),
    PackageSpec(
      name: 'monolib_openrouter',
      directoryName: 'monolib-openrouter',
      description:
          'Streaming, JSON, and timeout utilities for OpenRouter AI clients in Dart.',
      barrels: [
        BarrelSpec('monolib_openrouter.dart',
            'OpenRouter Utilities — Streaming Converters, Sinks & Timeouts'),
      ],
    ),
  ];

  // Parse all packages
  final List<ParsedPackage> parsedPackages = [];
  for (final pkg in packages) {
    parsedPackages.add(parsePackage(repoRoot, pkg));
  }

  // Generate Table of Contents
  buffer.writeln('## Table of Contents');
  buffer.writeln();
  for (final pkg in parsedPackages) {
    final pkgAnchor = anchor(pkg.spec.name);
    buffer.writeln('- [${pkg.spec.name}](#$pkgAnchor)');
    for (final barrel in pkg.barrels) {
      final barrelAnchor = anchor('${pkg.spec.name}-${barrel.spec.filename}');
      buffer.writeln(
          '  - [${barrel.spec.title}](#$barrelAnchor) (`package:${pkg.spec.name}/${barrel.spec.filename}`)');
    }
  }
  buffer.writeln();
  buffer.writeln('---');
  buffer.writeln();

  // Generate Packages
  for (final pkg in parsedPackages) {
    buffer.writeln('## `${pkg.spec.name}`');
    buffer.writeln();
    buffer.writeln(pkg.spec.description);
    buffer.writeln();

    for (final barrel in pkg.barrels) {
      final barrelAnchor = anchor('${pkg.spec.name}-${barrel.spec.filename}');
      buffer.writeln('<a id="$barrelAnchor"></a>');
      buffer.writeln('### ${barrel.spec.title}');
      buffer.writeln();
      buffer.writeln(
          '- **Import:** `import \'package:${pkg.spec.name}/${barrel.spec.filename}\';`');
      if (barrel.docComment.isNotEmpty) {
        buffer.writeln('- **Overview:** ${barrel.docComment}');
      }
      buffer.writeln();

      for (final file in barrel.files) {
        for (final entity in file.entities) {
          buffer.writeln('#### `${entity.signature}`');
          buffer.writeln();
          buffer.writeln('- **Source:** `${file.relativePath}`');
          buffer.writeln();

          if (entity.docComment.isNotEmpty) {
            buffer.writeln(entity.docComment);
            buffer.writeln();
          }

          if (entity.members.isNotEmpty) {
            buffer.writeln('##### Public Members');
            buffer.writeln();

            final constructors = entity.members
                .where((m) => m.kind == MemberKind.constructor)
                .toList();
            final properties = entity.members
                .where((m) => m.kind == MemberKind.property)
                .toList();
            final methods = entity.members
                .where((m) => m.kind == MemberKind.method)
                .toList();
            final enumValues = entity.members
                .where((m) => m.kind == MemberKind.enumValue)
                .toList();

            if (enumValues.isNotEmpty) {
              buffer.writeln('**Values:**');
              for (final val in enumValues) {
                if (val.summary.isNotEmpty) {
                  buffer.writeln('- `${val.signature}` — ${val.summary}');
                } else {
                  buffer.writeln('- `${val.signature}`');
                }
              }
              buffer.writeln();
            }

            if (constructors.isNotEmpty) {
              buffer.writeln('**Constructors:**');
              for (final c in constructors) {
                if (c.summary.isNotEmpty) {
                  buffer.writeln('- `${c.signature}` — ${c.summary}');
                } else {
                  buffer.writeln('- `${c.signature}`');
                }
              }
              buffer.writeln();
            }

            if (properties.isNotEmpty) {
              buffer.writeln('**Properties & Getters:**');
              for (final p in properties) {
                if (p.summary.isNotEmpty) {
                  buffer.writeln('- `${p.signature}` — ${p.summary}');
                } else {
                  buffer.writeln('- `${p.signature}`');
                }
              }
              buffer.writeln();
            }

            if (methods.isNotEmpty) {
              buffer.writeln('**Methods & Operators:**');
              for (final m in methods) {
                if (m.summary.isNotEmpty) {
                  buffer.writeln('- `${m.signature}` — ${m.summary}');
                } else {
                  buffer.writeln('- `${m.signature}`');
                }
              }
              buffer.writeln();
            }
          }

          buffer.writeln('---');
          buffer.writeln();
        }
      }
    }
  }

  final outputFile = File('${repoRoot.path}/monodoc.md');
  outputFile.writeAsStringSync(buffer.toString());
  stopwatch.stop();

  print('Successfully generated ${outputFile.path}');
  print('Total lines: ${outputFile.readAsLinesSync().length}');
  print('Execution time: ${stopwatch.elapsedMilliseconds} ms');
}

Directory findRepoRoot() {
  final scriptFile = File(Platform.script.toFilePath());
  Directory current = scriptFile.parent;
  while (true) {
    if (File('${current.path}/pubspec.yaml').existsSync() &&
        File('${current.path}/monolib-dart/pubspec.yaml').existsSync()) {
      return current;
    }
    final parent = current.parent;
    if (parent.path == current.path) {
      throw StateError(
          'Could not find repository root containing monolib-dart.');
    }
    current = parent;
  }
}

String anchor(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_-]'), '-')
      .replaceAll(RegExp(r'-+'), '-');
}

class PackageSpec {
  final String name;
  final String directoryName;
  final String description;
  final List<BarrelSpec> barrels;

  PackageSpec({
    required this.name,
    required this.directoryName,
    required this.description,
    required this.barrels,
  });
}

class BarrelSpec {
  final String filename;
  final String title;

  BarrelSpec(this.filename, this.title);
}

class ParsedPackage {
  final PackageSpec spec;
  final List<ParsedBarrel> barrels;

  ParsedPackage(this.spec, this.barrels);
}

class ParsedBarrel {
  final BarrelSpec spec;
  final String docComment;
  final List<ParsedFile> files;

  ParsedBarrel(this.spec, this.docComment, this.files);
}

class ParsedFile {
  final String relativePath;
  final List<ParsedEntity> entities;

  ParsedFile(this.relativePath, this.entities);
}

enum EntityKind {
  clazz,
  extension,
  enumType,
  mixinType,
  typedefType,
  functionType,
}

class ParsedEntity {
  final EntityKind kind;
  final String name;
  final String signature;
  final String docComment;
  final List<ParsedMember> members;

  ParsedEntity({
    required this.kind,
    required this.name,
    required this.signature,
    required this.docComment,
    required this.members,
  });
}

enum MemberKind {
  constructor,
  property,
  method,
  enumValue,
}

class ParsedMember {
  final MemberKind kind;
  final String signature;
  final String summary;

  ParsedMember({
    required this.kind,
    required this.signature,
    required this.summary,
  });
}

ParsedPackage parsePackage(Directory repoRoot, PackageSpec spec) {
  final pkgDir = Directory('${repoRoot.path}/${spec.directoryName}');
  final List<ParsedBarrel> barrels = [];

  for (final barrelSpec in spec.barrels) {
    final barrelFile = File('${pkgDir.path}/lib/${barrelSpec.filename}');
    if (!barrelFile.existsSync()) {
      continue;
    }

    final barrelContent = barrelFile.readAsStringSync();
    final barrelDoc = extractTopDocComment(barrelContent);
    final exportedPaths = extractExports(barrelContent);

    final List<ParsedFile> parsedFiles = [];
    for (final exp in exportedPaths) {
      final targetFile = File('${pkgDir.path}/lib/$exp');
      if (!targetFile.existsSync()) {
        continue;
      }
      final relativePath = '${spec.directoryName}/lib/$exp';
      final fileContent = targetFile.readAsStringSync();
      final entities = parseDartFile(fileContent, relativePath);
      parsedFiles.add(ParsedFile(relativePath, entities));
    }

    barrels.add(ParsedBarrel(barrelSpec, barrelDoc, parsedFiles));
  }

  return ParsedPackage(spec, barrels);
}

String extractTopDocComment(String content) {
  final lines = content.split('\n');
  final docLines = <String>[];
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('///')) {
      docLines.add(cleanDocLine(trimmed));
    } else if (trimmed.startsWith('library;') || trimmed.isEmpty) {
      if (docLines.isNotEmpty) break;
    } else {
      break;
    }
  }
  return docLines.join('\n').trim();
}

List<String> extractExports(String content) {
  final exportRegex = RegExp("export\\s+['\"]([^'\"]+)['\"]");
  final matches = exportRegex.allMatches(content);
  return matches.map((m) => m.group(1)!).toList();
}

String cleanDocLine(String line) {
  if (line.startsWith('/// ')) {
    return line.substring(4);
  } else if (line == '///') {
    return '';
  }
  return line;
}

List<ParsedEntity> parseDartFile(String content, String relativePath) {
  final List<ParsedEntity> entities = [];
  final lines = content.split('\n');

  int i = 0;
  final currentDoc = <String>[];

  while (i < lines.length) {
    final line = lines[i];
    final trimmed = line.trim();

    if (trimmed.startsWith('///')) {
      currentDoc.add(cleanDocLine(trimmed));
      i++;
      continue;
    }

    if (trimmed.startsWith('//') ||
        trimmed.startsWith('@') ||
        trimmed.isEmpty ||
        trimmed.startsWith('import ') ||
        trimmed.startsWith('part ') ||
        trimmed.startsWith('library;')) {
      if (trimmed.isEmpty || trimmed.startsWith('import ')) {
        currentDoc.clear();
      }
      i++;
      continue;
    }

    // Check for typedef
    final typedefMatch =
        RegExp(r'^typedef\s+([A-Za-z0-9_]+)(<[^>]+>)?\s*=').firstMatch(trimmed);
    if (typedefMatch != null) {
      final name = typedefMatch.group(1)!;
      if (name.startsWith('_')) {
        currentDoc.clear();
        i = advancePastSemicolon(lines, i);
        continue;
      }
      final signature = collectSignatureUntilSemicolon(lines, i);
      entities.add(ParsedEntity(
        kind: EntityKind.typedefType,
        name: name,
        signature: signature,
        docComment: currentDoc.join('\n').trim(),
        members: const [],
      ));
      currentDoc.clear();
      i = advancePastSemicolon(lines, i);
      continue;
    }

    // Check for class / abstract class / mixin class
    final classMatch = RegExp(
            r'^(abstract\s+class|class|mixin\s+class)\s+([A-Za-z0-9_]+)(<[^>]+>)?')
        .firstMatch(trimmed);
    if (classMatch != null) {
      final name = classMatch.group(2)!;
      if (name.startsWith('_')) {
        currentDoc.clear();
        i = advancePastBody(lines, i);
        continue;
      }
      final signature = collectDeclarationSignature(lines, i);
      final doc = currentDoc.join('\n').trim();
      currentDoc.clear();

      final classBody = extractBodyLines(lines, i);
      final members = parseMembers(classBody, name);

      entities.add(ParsedEntity(
        kind: EntityKind.clazz,
        name: name,
        signature: signature,
        docComment: doc,
        members: members,
      ));

      i = advancePastBody(lines, i);
      continue;
    }

    // Check for enum
    final enumMatch = RegExp(r'^enum\s+([A-Za-z0-9_]+)').firstMatch(trimmed);
    if (enumMatch != null) {
      final name = enumMatch.group(1)!;
      if (name.startsWith('_')) {
        currentDoc.clear();
        i = advancePastBody(lines, i);
        continue;
      }
      final signature = collectDeclarationSignature(lines, i);
      final doc = currentDoc.join('\n').trim();
      currentDoc.clear();

      final enumBody = extractBodyLines(lines, i);
      final members = parseEnumMembers(enumBody);

      entities.add(ParsedEntity(
        kind: EntityKind.enumType,
        name: name,
        signature: signature,
        docComment: doc,
        members: members,
      ));

      i = advancePastBody(lines, i);
      continue;
    }

    // Check for mixin
    final mixinMatch =
        RegExp(r'^mixin\s+([A-Za-z0-9_]+)(<[^>]+>)?').firstMatch(trimmed);
    if (mixinMatch != null) {
      final name = mixinMatch.group(1)!;
      if (name.startsWith('_')) {
        currentDoc.clear();
        i = advancePastBody(lines, i);
        continue;
      }
      final signature = collectDeclarationSignature(lines, i);
      final doc = currentDoc.join('\n').trim();
      currentDoc.clear();

      final mixinBody = extractBodyLines(lines, i);
      final members = parseMembers(mixinBody, name);

      entities.add(ParsedEntity(
        kind: EntityKind.mixinType,
        name: name,
        signature: signature,
        docComment: doc,
        members: members,
      ));

      i = advancePastBody(lines, i);
      continue;
    }

    // Check for extension
    final extensionMatch =
        RegExp(r'^extension\s+([A-Za-z0-9_]+)?(<[^>]+>)?\s+on\s+')
            .firstMatch(trimmed);
    if (extensionMatch != null) {
      final name = extensionMatch.group(1) ?? 'UnnamedExtension';
      if (name.startsWith('_')) {
        currentDoc.clear();
        i = advancePastBody(lines, i);
        continue;
      }
      final signature = collectDeclarationSignature(lines, i);
      final doc = currentDoc.join('\n').trim();
      currentDoc.clear();

      final extBody = extractBodyLines(lines, i);
      final members = parseMembers(extBody, name);

      entities.add(ParsedEntity(
        kind: EntityKind.extension,
        name: name,
        signature: signature,
        docComment: doc,
        members: members,
      ));

      i = advancePastBody(lines, i);
      continue;
    }

    // Check for top-level function
    if (trimmed.contains('(') && !trimmed.contains('=')) {
      final signature = collectFunctionHeader(lines, i);
      if (signature.isNotEmpty) {
        final funcName = extractCallableName(signature);
        if (funcName != null && !funcName.startsWith('_')) {
          entities.add(ParsedEntity(
            kind: EntityKind.functionType,
            name: funcName,
            signature: signature,
            docComment: currentDoc.join('\n').trim(),
            members: const [],
          ));
        }
        currentDoc.clear();
        i = advancePastBody(lines, i);
        continue;
      }
    }

    currentDoc.clear();
    i++;
  }

  return entities;
}

String collectSignatureUntilSemicolon(List<String> lines, int startIndex) {
  final buffer = StringBuffer();
  for (int i = startIndex; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) break;
    if (buffer.isNotEmpty) buffer.write(' ');
    buffer.write(line);
    if (line.endsWith(';')) break;
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
}

String collectDeclarationSignature(List<String> lines, int startIndex) {
  final buffer = StringBuffer();
  for (int i = startIndex; i < lines.length; i++) {
    final line = lines[i].trim();
    if (buffer.isNotEmpty) buffer.write(' ');
    buffer.write(line);
    if (line.contains('{')) break;
  }
  var sig = buffer.toString();
  final braceIdx = sig.indexOf('{');
  if (braceIdx != -1) sig = sig.substring(0, braceIdx).trim();
  return sig.replaceAll(RegExp(r'\s+'), ' ');
}

String collectFunctionHeader(List<String> lines, int startIndex) {
  final buffer = StringBuffer();
  int parenDepth = 0;
  bool sawParen = false;

  for (int i = startIndex; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    if (buffer.isNotEmpty) buffer.write(' ');
    buffer.write(line);

    for (int c = 0; c < line.length; c++) {
      final ch = line[c];
      if (ch == '(') {
        parenDepth++;
        sawParen = true;
      } else if (ch == ')') {
        if (parenDepth > 0) parenDepth--;
      }
    }

    if (sawParen && parenDepth <= 0) break;
  }

  var sig = buffer.toString();
  final braceIdx = sig.indexOf('{');
  if (braceIdx != -1) sig = sig.substring(0, braceIdx).trim();
  final arrowIdx = sig.indexOf('=>');
  if (arrowIdx != -1) sig = sig.substring(0, arrowIdx).trim();
  if (sig.endsWith(';')) sig = sig.substring(0, sig.length - 1).trim();

  return sig.replaceAll(RegExp(r'\s+'), ' ');
}

String? extractCallableName(String signature) {
  final parenIdx = signature.indexOf('(');
  if (parenIdx == -1) return null;
  var beforeParen = signature.substring(0, parenIdx).trim();
  final angleIdx = beforeParen.indexOf('<');
  if (angleIdx != -1) beforeParen = beforeParen.substring(0, angleIdx).trim();
  final parts = beforeParen.split(RegExp(r'\s+'));
  return parts.isEmpty ? null : parts.last;
}

int advancePastSemicolon(List<String> lines, int startIndex) {
  for (int i = startIndex; i < lines.length; i++) {
    if (lines[i].trim().endsWith(';')) return i + 1;
  }
  return startIndex + 1;
}

int advancePastBody(List<String> lines, int startIndex) {
  int parenDepth = 0;
  int bodyBraces = 0;
  bool insideBody = false;

  for (int i = startIndex; i < lines.length; i++) {
    final line = lines[i];
    for (int c = 0; c < line.length; c++) {
      final ch = line[c];
      if (ch == '(') {
        parenDepth++;
      } else if (ch == ')') {
        if (parenDepth > 0) parenDepth--;
      } else if (ch == '{') {
        if (parenDepth == 0) {
          bodyBraces++;
          insideBody = true;
        }
      } else if (ch == '}') {
        if (parenDepth == 0 && insideBody) {
          bodyBraces--;
          if (bodyBraces <= 0) {
            return i + 1;
          }
        }
      }
    }
    if (!insideBody && parenDepth == 0 && line.trim().endsWith(';')) {
      return i + 1;
    }
  }
  return lines.length;
}

List<String> extractBodyLines(List<String> lines, int startIndex) {
  final body = <String>[];
  int parenDepth = 0;
  int bodyBraces = 0;

  for (int i = startIndex; i < lines.length; i++) {
    final line = lines[i];
    final wasInside = bodyBraces > 0;

    for (int c = 0; c < line.length; c++) {
      final ch = line[c];
      if (ch == '(') {
        parenDepth++;
      } else if (ch == ')') {
        if (parenDepth > 0) parenDepth--;
      } else if (ch == '{') {
        if (parenDepth == 0) {
          bodyBraces++;
        }
      } else if (ch == '}') {
        if (parenDepth == 0 && bodyBraces > 0) {
          bodyBraces--;
          if (bodyBraces <= 0) {
            return body;
          }
        }
      }
    }

    // Only add lines strictly inside the body (not the line containing the first opening '{')
    if (wasInside && bodyBraces > 0) {
      body.add(line);
    }
  }
  return body;
}

List<ParsedMember> parseMembers(List<String> bodyLines, String enclosingName) {
  final List<ParsedMember> members = [];
  final docBuffer = <String>[];
  int i = 0;

  while (i < bodyLines.length) {
    final line = bodyLines[i];
    final trimmed = line.trim();

    if (trimmed.startsWith('///')) {
      docBuffer.add(cleanDocLine(trimmed));
      i++;
      continue;
    }

    if (trimmed.startsWith('//') ||
        trimmed.startsWith('@') ||
        trimmed.isEmpty) {
      if (trimmed.isEmpty) docBuffer.clear();
      i++;
      continue;
    }

    // In standard Dart formatting, member declarations start at indentation 2
    // Anything indented by 3 or more spaces is part of a body
    if (!line.startsWith('  ') || line.startsWith('   ') || trimmed == '}') {
      docBuffer.clear();
      i++;
      continue;
    }

    // Collect full signature of this member
    final sig = collectFullMemberHeader(bodyLines, i);
    final docSummary = docBuffer.isNotEmpty ? docBuffer.first : '';
    docBuffer.clear();

    if (sig.isNotEmpty && !isPrivate(sig, enclosingName)) {
      final kind = classifyMember(sig, enclosingName);
      members.add(ParsedMember(
        kind: kind,
        signature: sig,
        summary: docSummary,
      ));
    }

    i = advancePastMemberBody(bodyLines, i);
  }

  return members;
}

List<ParsedMember> parseEnumMembers(List<String> bodyLines) {
  final List<ParsedMember> members = [];
  final docBuffer = <String>[];

  for (final line in bodyLines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('///')) {
      docBuffer.add(cleanDocLine(trimmed));
      continue;
    }
    if (trimmed.isEmpty ||
        trimmed.startsWith('//') ||
        trimmed.startsWith('@')) {
      continue;
    }

    final match = RegExp(r'^([a-zA-Z0-9_]+)[,;]').firstMatch(trimmed);
    if (match != null) {
      final name = match.group(1)!;
      final summary = docBuffer.isNotEmpty ? docBuffer.first : '';
      members.add(ParsedMember(
        kind: MemberKind.enumValue,
        signature: name,
        summary: summary,
      ));
      docBuffer.clear();
    }
  }

  return members;
}

String collectFullMemberHeader(List<String> lines, int startIndex) {
  final buffer = StringBuffer();
  int parenDepth = 0;
  bool sawParen = false;

  for (int i = startIndex; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    if (buffer.isNotEmpty) buffer.write(' ');
    buffer.write(line);

    for (int c = 0; c < line.length; c++) {
      final ch = line[c];
      if (ch == '(') {
        parenDepth++;
        sawParen = true;
      } else if (ch == ')') {
        if (parenDepth > 0) parenDepth--;
      }
    }

    // Check if we hit the end of the header
    // Header ends before block body '{', before arrow '=>', or at semicolon ';'
    if (sawParen && parenDepth <= 0) {
      if (line.contains('{') || line.contains('=>') || line.endsWith(';')) {
        break;
      }
    } else if (!sawParen &&
        (line.contains('{') || line.contains('=>') || line.endsWith(';'))) {
      break;
    }
  }

  var sig = buffer.toString();
  final braceIdx = findOutsideParens(sig, '{');
  if (braceIdx != -1) sig = sig.substring(0, braceIdx).trim();
  final arrowIdx = findOutsideParens(sig, '=');
  if (arrowIdx != -1 && sig.contains('=>')) {
    final actualArrowIdx = sig.indexOf('=>');
    sig = sig.substring(0, actualArrowIdx).trim();
  }
  final colonIdx = findOutsideParens(sig, ':');
  if (colonIdx != -1 && sig.contains('(')) {
    sig = sig.substring(0, colonIdx).trim();
  }
  if (sig.endsWith(';')) sig = sig.substring(0, sig.length - 1).trim();

  return sig.replaceAll(RegExp(r'\s+'), ' ');
}

int findOutsideParens(String text, String char) {
  int parenDepth = 0;
  for (int i = 0; i < text.length; i++) {
    final c = text[i];
    if (c == '(') {
      parenDepth++;
    } else if (c == ')') {
      if (parenDepth > 0) parenDepth--;
    } else if (parenDepth == 0 && c == char) {
      return i;
    }
  }
  return -1;
}

bool isPrivate(String signature, String enclosingName) {
  if (signature.contains('$enclosingName._') || signature.startsWith('_')) {
    return true;
  }
  // Check for private getter/setter
  final getterSetter = RegExp(r'\b(get|set)\s+(_[A-Za-z0-9_]+)\b');
  if (getterSetter.hasMatch(signature)) {
    return true;
  }
  // Check for method/function name starting with _ (before < or ()
  final methodMatch =
      RegExp(r'(_[A-Za-z0-9_]+)\s*(<[^>]+>)?\s*\(').firstMatch(signature);
  if (methodMatch != null) {
    return true;
  }
  // Check for private field name
  final fieldMatch =
      RegExp(r'\b(_[A-Za-z0-9_]+)\s*(=|;|$)').firstMatch(signature);
  if (fieldMatch != null) {
    return true;
  }
  return false;
}

MemberKind classifyMember(String signature, String enclosingName) {
  // Check for constructor
  if (RegExp('^(const\\s+|factory\\s+)?$enclosingName(\\.[a-zA-Z0-9_]+)?\\(')
      .hasMatch(signature)) {
    return MemberKind.constructor;
  }
  // Check for getter/setter or field
  if (signature.contains(' get ') ||
      signature.contains(' set ') ||
      (signature.startsWith('final ') && !signature.contains('(')) ||
      (signature.startsWith('const ') && !signature.contains('(')) ||
      (signature.startsWith('late final ') && !signature.contains('('))) {
    return MemberKind.property;
  }
  return MemberKind.method;
}

int advancePastMemberBody(List<String> lines, int startIndex) {
  int parenDepth = 0;
  int bodyBraces = 0;
  bool insideBody = false;

  for (int i = startIndex; i < lines.length; i++) {
    final line = lines[i];
    for (int c = 0; c < line.length; c++) {
      final ch = line[c];
      if (ch == '(') {
        parenDepth++;
      } else if (ch == ')') {
        if (parenDepth > 0) parenDepth--;
      } else if (ch == '{') {
        if (parenDepth == 0) {
          bodyBraces++;
          insideBody = true;
        }
      } else if (ch == '}') {
        if (parenDepth == 0 && insideBody) {
          bodyBraces--;
          if (bodyBraces <= 0) {
            return i + 1;
          }
        }
      }
    }
    if (!insideBody && parenDepth == 0 && line.trim().endsWith(';')) {
      return i + 1;
    }
  }
  return startIndex + 1;
}
