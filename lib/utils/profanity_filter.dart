/// Lightweight client-side check for obviously inappropriate team names.
/// Not exhaustive — server-side moderation is the real safeguard.
class ProfanityFilter {
  ProfanityFilter._();

  // Common profane / slur terms (lowercased). Keeps the app family-friendly
  // without pulling in a third-party package.
  static final _blocked = <String>{
    'ass',
    'asshole',
    'bastard',
    'bitch',
    'blowjob',
    'bollocks',
    'cock',
    'crap',
    'cunt',
    'damn',
    'dick',
    'dildo',
    'dyke',
    'fag',
    'faggot',
    'fuck',
    'fucker',
    'fucking',
    'goddamn',
    'hell',
    'homo',
    'jerk',
    'kike',
    'milf',
    'motherfucker',
    'nazi',
    'nigga',
    'nigger',
    'piss',
    'prick',
    'pussy',
    'retard',
    'shit',
    'slut',
    'spic',
    'tit',
    'tits',
    'twat',
    'wanker',
    'whore',
  };

  /// Returns `true` when [text] contains a blocked word (whole-word match).
  static bool containsProfanity(String text) {
    final normalised = text.toLowerCase().replaceAll(RegExp(r'[^a-z]'), ' ');
    final words = normalised.split(RegExp(r'\s+'));
    return words.any(_blocked.contains);
  }
}
