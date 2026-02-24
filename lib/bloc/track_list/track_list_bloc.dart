import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_player/models/track.dart';
import 'package:music_player/repositories/track_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'track_list_event.dart';
part 'track_list_state.dart';

const _pageSize = 50;

class TrackListBloc extends Bloc<TrackListEvent, TrackListState> {
  final TrackRepository _trackRepository;

  TrackListBloc(this._trackRepository) : super(const TrackListState()) {
    on<FetchTracks>(
      _onFetchTracks,
      transformer: (events, mapper) =>
          events.debounceTime(const Duration(milliseconds: 300)).switchMap(mapper),
    );
    on<FetchMoreTracks>(_onFetchMoreTracks);
  }

  Future<void> _onFetchTracks(
    FetchTracks event,
    Emitter<TrackListState> emit,
  ) async {
    emit(state.copyWith(
      status: TrackListStatus.loading,
      tracks: [],
      groupedTracks: null,
      hasReachedMax: false,
      forceGroupedTracks: true, // This ensures groupedTracks is cleared during new searches
    ));
    try {
      final tracks = await _trackRepository.getTracks(event.query, 0, _pageSize) ?? [];
      final groupedTracks = _groupTracks(tracks);
      emit(
        state.copyWith(
          status: TrackListStatus.success,
          tracks: tracks,
          groupedTracks: groupedTracks,
          hasReachedMax: tracks.length < _pageSize,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: TrackListStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onFetchMoreTracks(
    FetchMoreTracks event,
    Emitter<TrackListState> emit,
  ) async {
    if (state.hasReachedMax) return;

    try {
      final tracks = await _trackRepository.getTracks(event.query, state.tracks.length, _pageSize) ?? [];
      if (tracks.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        final allTracks = List.of(state.tracks)..addAll(tracks);
        final groupedTracks = _groupTracks(allTracks);
        emit(
          state.copyWith(
            status: TrackListStatus.success,
            tracks: allTracks,
            groupedTracks: groupedTracks,
            hasReachedMax: tracks.length < _pageSize,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(status: TrackListStatus.failure, errorMessage: e.toString()));
    }
  }

  Map<String, List<Track>> _groupTracks(List<Track> tracks) {
    final groupedTracks = <String, List<Track>>{};
    for (var track in tracks) {
      (groupedTracks[track.artist] ??= []).add(track);
    }
    return groupedTracks;
  }
}
