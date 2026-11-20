/// Fold Turkish letters and common diacritics without changing the shown title.
String normalizeZikrSearch(String input) {
  const groups = {
    'a': 'àáâãäåāăą',
    'c': 'çćč',
    'e': 'èéêëēėę',
    'g': 'ğ',
    'i': 'ıìíîïī',
    'n': 'ñń',
    'o': 'òóôõöō',
    's': 'şśš',
    'u': 'ùúûüū',
    'y': 'ýÿ',
    'z': 'źżž',
  };
  var result = input.toLowerCase();
  for (final entry in groups.entries) {
    for (final letter in entry.value.runes) {
      result = result.replaceAll(String.fromCharCode(letter), entry.key);
    }
  }
  return result
      .replaceAll(RegExp(r'[\u0300-\u036f]'), '')
      .replaceAll(RegExp("['’ʼ]"), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
