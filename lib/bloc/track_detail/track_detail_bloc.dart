import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_player/models/lyrics.dart';
import 'package:music_player/models/track.dart';
import 'package:music_player/repositories/track_repository.dart';

part 'track_detail_event.dart';
part 'track_detail_state.dart';

class TrackDetailBloc extends Bloc<TrackDetailEvent, TrackDetailState> {
  final TrackRepository _trackRepository;

  TrackDetailBloc(this._trackRepository) : super(const TrackDetailState()) {
    on<FetchTrackDetail>(_onFetchTrackDetail);
    on<FetchLyrics>(_onFetchLyrics);
  }

  Future<void> _onFetchTrackDetail(
    FetchTrackDetail event,
    Emitter<TrackDetailState> emit,
  ) async {
    emit(state.copyWith(status: TrackDetailStatus.loading));
    try {
      final track = await _trackRepository.getTrackDetails(event.trackId);
      emit(state.copyWith(
        status: TrackDetailStatus.success,
        track: track,
      ));
    } catch (e) {
      emit(state.copyWith(status: TrackDetailStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onFetchLyrics(
    FetchLyrics event,
    Emitter<TrackDetailState> emit,
  ) async {
    try {
      print(
          'Fetching lyrics for: ${event.trackName}, ${event.artistName}, ${event.albumName}, ${event.duration}');
      final lyrics = await _trackRepository.getLyrics(
        event.trackName,
        event.artistName,
        event.albumName,
        event.duration,
      );
      emit(state.copyWith(lyrics: lyrics, status: TrackDetailStatus.success));
    } catch (e) {
      emit(state.copyWith(status: TrackDetailStatus.failure, errorMessage: e.toString()));
    }
  }
}
