import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/bloc/track_list/track_list_bloc.dart';
import 'package:music_player/models/track.dart';
import 'package:music_player/screens/track_details_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _audioPlayer = AudioPlayer();
  int? _playingTrackId;

  @override
  void initState() {
    super.initState();
    context.read<TrackListBloc>().add(const FetchTracks());
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() {}); // Rebuild to show/hide the clear button
      context.read<TrackListBloc>().add(FetchTracks(
          query: _searchController.text.isEmpty
              ? 'a'
              : _searchController.text));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Changed to black for deeper contrast
      appBar: AppBar(
        title: const Text('Music Library',
            style:
                TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search tracks...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[900], // Darker search field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<TrackListBloc, TrackListState>(
              builder: (context, state) {
                switch (state.status) {
                  case TrackListStatus.failure:
                    if (state.errorMessage.contains('NO INTERNET CONNECTION')) {
                      return const Center(
                        child: Text(
                          'Internet disconnected. Please check your connection.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return Center(
                        child: Text(state.errorMessage,
                            style: const TextStyle(color: Colors.white)));
                  case TrackListStatus.loading:
                    return const Center(child: CircularProgressIndicator());
                  case TrackListStatus.success:
                    if (state.groupedTracks == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.tracks.isEmpty) {
                      return const Center(
                          child: Text('No tracks found',
                              style: TextStyle(color: Colors.white)));
                    }

                    final groupedTracks = state.groupedTracks!;
                    final sortedArtists = groupedTracks.keys.toList()..sort();

                    final items = [];
                    for (var artist in sortedArtists) {
                      items.add(artist);
                      items.addAll(groupedTracks[artist]!);
                    }
                    if (!state.hasReachedMax) {
                      items.add(null); // for loading indicator
                    }

                    return ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        final item = items[index];

                        if (item == null) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (item is String) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }

                        final track = item as Track;
                        final isPlaying = track.id == _playingTrackId;

                        void handlePlayPause() {
                          if (isPlaying) {
                            _audioPlayer.pause();
                            setState(() {
                              _playingTrackId = null;
                            });
                          } else {
                            _audioPlayer.play(UrlSource(track.preview));
                            setState(() {
                              _playingTrackId = track.id;
                            });
                          }
                        }

                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: Image.network(
                              track.albumCover ?? '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.music_note,
                                      size: 50, color: Colors.white54),
                            ),
                          ),
                          title: Text(track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text(track.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[400])),
                          trailing: IconButton(
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: handlePlayPause,
                          ),
                          onTap: () {
                            final trackList =
                                state.tracks.whereType<Track>().toList();
                            final trackIndex =
                                trackList.indexWhere((t) => t.id == track.id);
                            if (trackIndex != -1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TrackDetailsScreen(
                                    trackList: trackList,
                                    initialIndex: trackIndex,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        final item = items[index];
                        if (index + 1 >= items.length)
                          return const SizedBox.shrink();
                        final nextItem = items[index + 1];

                        if (item is String) {
                          return const SizedBox(height: 8);
                        }

                        if (item is Track && nextItem is Track) {
                          return const Divider(
                            color: Colors.white24,
                            height: 1,
                            indent: 82,
                            endIndent: 16,
                          );
                        }

                        if (item is Track && nextItem is String) {
                          return const Divider(
                            color: Colors.white54,
                            height: 24,
                          );
                        }

                        return const SizedBox.shrink();
                      },
                      itemCount: items.length,
                      controller: _scrollController,
                    );
                  default:
                    return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TrackListBloc>().add(FetchMoreTracks(
          query: _searchController.text.isEmpty
              ? 'a'
              : _searchController.text));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
