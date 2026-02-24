part of 'track_detail_bloc.dart';

abstract class TrackDetailEvent extends Equatable {
  const TrackDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchTrackDetail extends TrackDetailEvent {
  final int trackId;

  const FetchTrackDetail(this.trackId);
}

class FetchLyrics extends TrackDetailEvent {
  final String trackName;
  final String artistName;
  final String albumName;
  final int duration;

  const FetchLyrics({
    required this.trackName,
    required this.artistName,
    required this.albumName,
    required this.duration,
  });
}
