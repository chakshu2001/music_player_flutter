class Lyrics {
  final String? lyrics;
  final bool instrumental;

  Lyrics({this.lyrics, this.instrumental = false});

  factory Lyrics.fromJson(Map<String, dynamic> json) {
    return Lyrics(
      lyrics: json['plainLyrics'],
      instrumental: json['instrumental'] ?? false,
    );
  }
}
