String normalizeMemoryPatchYaml(String raw) {
  return _normalizeRuntimeMemoryBlockScalars(stripMemoryPatchCodeFence(raw));
}

String stripMemoryPatchCodeFence(String raw) {
  final trimmed = raw.trim();
  final match = RegExp(
    r'^```(?:markdown|md|yaml|yml)?\s*([\s\S]*?)\s*```$',
    caseSensitive: false,
  ).firstMatch(trimmed);
  return match?.group(1)?.trim() ?? trimmed;
}

String _normalizeRuntimeMemoryBlockScalars(String yamlText) {
  if (yamlText.isEmpty) {
    return yamlText;
  }

  final lines = yamlText.split('\n');
  final output = <String>[];
  var runtimeMemoryIndent = -1;
  var index = 0;
  while (index < lines.length) {
    final line = lines[index];
    final runtimeMemoryLine = _runtimeMemoryRootMatch(line);
    if (runtimeMemoryLine != null) {
      runtimeMemoryIndent = runtimeMemoryLine.indent;
      output.add(line);
      index += 1;
      break;
    }
    output.add(line);
    index += 1;
  }

  if (runtimeMemoryIndent < 0) {
    return output.join('\n').trim();
  }

  while (index < lines.length) {
    final line = lines[index];
    if (line.trim().isEmpty) {
      output.add(line);
      index += 1;
      continue;
    }

    final field = _runtimeMemoryFieldMatch(line);
    if (field == null || field.indent <= runtimeMemoryIndent) {
      output.add(line);
      index += 1;
      continue;
    }

    final valuePart = field.valuePart;
    if (_startsWithBlockScalar(valuePart)) {
      final end = _findFieldBlockEnd(
        lines,
        index + 1,
        field.indent,
        runtimeMemoryIndent,
      );
      output.addAll(lines.sublist(index, end));
      index = end;
      continue;
    }

    final blockEnd = _findFieldBlockEnd(
      lines,
      index + 1,
      field.indent,
      runtimeMemoryIndent,
    );
    if (blockEnd <= index + 1) {
      output.add(line);
      index += 1;
      continue;
    }

    final continuationLines = lines.sublist(index + 1, blockEnd);
    final rewritten = _rewriteRuntimeMemoryField(
      field: field,
      continuationLines: continuationLines,
    );
    if (rewritten == null) {
      output.add(line);
      index += 1;
      continue;
    }

    output.addAll(rewritten);
    index = blockEnd;
  }

  return output.join('\n').trim();
}

List<String>? _rewriteRuntimeMemoryField({
  required _RuntimeMemoryFieldMatch field,
  required List<String> continuationLines,
}) {
  if (continuationLines.isEmpty) {
    return null;
  }

  final leadingContent = field.valuePart.trim();
  final normalizedContentLines = <String>[
    if (leadingContent.isNotEmpty) leadingContent,
    ...continuationLines,
  ];
  final contentIndent = _minimumContentIndent(
    continuationLines,
    hasLeadingInlineValue: leadingContent.isNotEmpty,
  );
  final pad = ' ' * (field.indent + 2);
  final rewritten = <String>['${field.prefix}${field.key}: |-'];
  for (var index = 0; index < normalizedContentLines.length; index += 1) {
    final line = normalizedContentLines[index];
    if (index == 0 && leadingContent.isNotEmpty) {
      rewritten.add('$pad$leadingContent');
      continue;
    }
    rewritten.add('$pad${_stripIndent(line, contentIndent)}');
  }
  return rewritten;
}

int _findFieldBlockEnd(
  List<String> lines,
  int start,
  int fieldIndent,
  int runtimeMemoryIndent,
) {
  var index = start;
  while (index < lines.length) {
    final line = lines[index];
    if (line.trim().isEmpty) {
      index += 1;
      continue;
    }
    if (_isRuntimeMemorySiblingField(line, fieldIndent)) {
      break;
    }
    if (_leadingSpaceCount(line) <= runtimeMemoryIndent &&
        _looksLikeYamlKey(line)) {
      break;
    }
    index += 1;
  }
  return index;
}

int _minimumContentIndent(
  List<String> contentLines, {
  required bool hasLeadingInlineValue,
}) {
  var indent = -1;
  for (final line in contentLines) {
    if (line.trim().isEmpty) {
      continue;
    }
    final leading = _leadingSpaceCount(line);
    if (indent < 0 || leading < indent) {
      indent = leading;
    }
  }
  if (indent < 0) {
    return hasLeadingInlineValue ? 0 : 2;
  }
  return indent;
}

bool _startsWithBlockScalar(String valuePart) {
  final trimmed = valuePart.trimLeft();
  return trimmed.startsWith('|') || trimmed.startsWith('>');
}

bool _looksLikeYamlKey(String line) {
  return RegExp(r'^\s*[\w-]+\s*:').hasMatch(line);
}

bool _isRuntimeMemorySiblingField(String line, int fieldIndent) {
  final match = _runtimeMemoryFieldMatch(line);
  return match != null && match.indent == fieldIndent;
}

int _leadingSpaceCount(String line) {
  var count = 0;
  while (count < line.length && line.codeUnitAt(count) == 0x20) {
    count += 1;
  }
  return count;
}

_RuntimeMemoryRootMatch? _runtimeMemoryRootMatch(String line) {
  final match = RegExp(r'^(\s*)runtimeMemory\s*:\s*$').firstMatch(line);
  if (match == null) {
    return null;
  }
  return _RuntimeMemoryRootMatch(prefix: match.group(1)!);
}

_RuntimeMemoryFieldMatch? _runtimeMemoryFieldMatch(String line) {
  final match = RegExp(
    r'^(\s*)(runtimeState|runtimeThreads|storySummary|continuityIndex|chapterArchiveMarkdown)\s*:(.*)$',
  ).firstMatch(line);
  if (match == null) {
    return null;
  }
  return _RuntimeMemoryFieldMatch(
    prefix: match.group(1)!,
    key: match.group(2)!,
    valuePart: match.group(3) ?? '',
  );
}

class _RuntimeMemoryFieldMatch {
  const _RuntimeMemoryFieldMatch({
    required this.prefix,
    required this.key,
    required this.valuePart,
  });

  final String prefix;
  final String key;
  final String valuePart;

  int get indent => prefix.length;
}

String _stripIndent(String line, int indent) {
  if (line.trim().isEmpty || indent <= 0) {
    return line.trimRight();
  }
  var consumed = 0;
  while (consumed < line.length && consumed < indent) {
    if (line.codeUnitAt(consumed) != 0x20) {
      break;
    }
    consumed += 1;
  }
  return line.substring(consumed).trimRight();
}

class _RuntimeMemoryRootMatch {
  const _RuntimeMemoryRootMatch({required this.prefix});

  final String prefix;

  int get indent => prefix.length;
}
