class StringMatch {

  static double fraction(String first, String second) {
    // if both are null
    if(first == null && second == null){
      return 1;
    }
    // as both are not null if one of them is null then return 0
    if(first == null || second == null){
      return 0;
    }

    first = first.replaceAll(RegExp(r'\s+\b|\b\s'), ''); // remove all whitespace
    second = second.replaceAll(RegExp(r'\s+\b|\b\s'), ''); // remove all whitespace

    // if both are empty strings
    if (first.isEmpty && second.isEmpty) {
      return 1;
    }
    // if only one is empty string
    if (first.isEmpty || second.isEmpty) {
      return 0;
    }

    first = first.trim().toUpperCase(); // trim and transform to upper case
    second = second.trim().toUpperCase(); // trim and transform to upper case

    // identical
    if (first == second) {
      return 1;
    }
    // both are 1-letter strings
    if (first.length == 1 && second.length == 1) {
      return 0;
    }
    // if either is a 1-letter string
    if (first.length < 2 || second.length < 2) {
      return 0;
    }

    final firstBigrams = <String, int>{};
    for (var i = 0; i < first.length - 1; i++) {
      final bigram = first.substring(i, i + 2);
      final count = firstBigrams.containsKey(bigram) ? firstBigrams[bigram] + 1 : 1;
      firstBigrams[bigram] = count;
    }

    var intersectionSize = 0;
    for (var i = 0; i < second.length - 1; i++) {
      final bigram = second.substring(i, i + 2);
      final count = firstBigrams.containsKey(bigram) ? firstBigrams[bigram] : 0;

      if (count > 0) {
        firstBigrams[bigram] = count - 1;
        intersectionSize++;
      }
    }

    return (2.0 * intersectionSize) / (first.length + second.length - 2);
  }

  static double percentage(String first, String second) => fraction(first, second) * 100;
}