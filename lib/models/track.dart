import 'package:equatable/equatable.dart';

class Track extends Equatable {
  final int id;
  final String title;
  final String artist;
  final String preview;
  final String? albumCover;
  final String albumName;
  final int duration;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.preview,
    this.albumCover,
    required this.albumName,
    required this.duration,
  });

  @override
  List<Object?> get props => [id, title, artist, preview, albumCover, albumName, duration];

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      title: json['title'],
      artist: json['artist'] != null ? json['artist']['name'] : '',
      preview: json['preview'] ?? '',
      albumCover: json['album'] != null ? json['album']['cover_big'] : null,
      albumName: json['album'] != null ? json['album']['title'] : '',
      duration: json['duration'] ?? 0,
    );
  }

  @override
  String toString() => 'Track { id: $id, title: $title, artist: $artist }';
}
