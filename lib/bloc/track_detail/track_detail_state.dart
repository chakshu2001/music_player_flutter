part of 'track_detail_bloc.dart';

enum TrackDetailStatus { initial, loading, success, failure }

class TrackDetailState extends Equatable {
  final TrackDetailStatus status;
  final Track? track;
  final String errorMessage;
  final Lyrics? lyrics;

  const TrackDetailState({
    this.status = TrackDetailStatus.initial,
    this.track,
    this.errorMessage = '',
    this.lyrics,
  });

  TrackDetailState copyWith({
    TrackDetailStatus? status,
    Track? track,
    String? errorMessage,
    Lyrics? lyrics,
  }) {
    return TrackDetailState(
      status: status ?? this.status,
      track: track ?? this.track,
      errorMessage: errorMessage ?? this.errorMessage,
      lyrics: lyrics ?? this.lyrics,
    );
  }

  @override
  List<Object?> get props => [status, track, errorMessage, lyrics];
}
