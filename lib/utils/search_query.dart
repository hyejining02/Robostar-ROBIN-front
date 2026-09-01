bool matchesSearchQuery(Iterable<Object?> fields, String rawQuery) {
  final query = rawQuery.trim().toLowerCase();
  if (query.isEmpty) return true;
  final source = fields.join(' ').toLowerCase();
  final orGroups = query.split(RegExp(r'\s+or\s+', caseSensitive: false));
  return orGroups.any((group) {
    final andTerms = group.split(RegExp(r'\s+and\s+', caseSensitive: false));
    return andTerms.every((rawTerm) {
      var term = rawTerm.trim();
      var excluded = false;
      if (term.startsWith('not ')) {
        excluded = true;
        term = term.substring(4).trim();
      }
      if (term.isEmpty) return true;
      final matched = term.contains('%')
          ? RegExp(
              '^${term.split('%').map(RegExp.escape).join('.*')}${r'$'}',
              caseSensitive: false,
            ).hasMatch(source)
          : source.contains(term);
      return excluded ? !matched : matched;
    });
  });
}
