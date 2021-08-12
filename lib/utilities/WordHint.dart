class WordHint {
  static String generate (String word) {
    final List<String> words = word.trim().split(" ");
    final List<String> hints = [];

    for(String word in words) {
      final String character = word[0];
      final String placeholder = '_' * (word.length - 1);
      hints.add("$character$placeholder");
    }

    return hints.join(" ");
  }
}