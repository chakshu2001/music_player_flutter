
part of 'track_list_bloc.dart';

abstract class TrackListEvent extends Equatable {
  const TrackListEvent();

  @override
  List<Object> get props => [];
}

class FetchTracks extends TrackListEvent {
  final String query;

  const FetchTracks({this.query = 'a'});
}

class FetchMoreTracks extends TrackListEvent {
  final String query;

  const FetchMoreTracks({this.query = 'a'});
}
