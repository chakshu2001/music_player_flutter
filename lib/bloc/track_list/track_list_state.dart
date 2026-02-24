part of 'track_list_bloc.dart';

enum TrackListStatus { initial, loading, success, failure }

class TrackListState extends Equatable {
  final TrackListStatus status;
  final List<Track> tracks;
  final bool hasReachedMax;
  final String errorMessage;
  final Map<String, List<Track>>? groupedTracks;

  const TrackListState({
    this.status = TrackListStatus.initial,
    this.tracks = const <Track>[],
    this.hasReachedMax = false,
    this.errorMessage = '',
    this.groupedTracks,
  });

  TrackListState copyWith({
    TrackListStatus? status,
    List<Track>? tracks,
    bool? hasReachedMax,
    String? errorMessage,
    Map<String, List<Track>>? groupedTracks,
    bool forceGroupedTracks = false,
  }) {
    return TrackListState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      groupedTracks: forceGroupedTracks
          ? groupedTracks
          : groupedTracks ?? this.groupedTracks,
    );
  }

  @override
  List<Object?> get props => [status, tracks, hasReachedMax, errorMessage, groupedTracks];
}
