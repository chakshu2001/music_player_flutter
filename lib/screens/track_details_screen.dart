import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/bloc/track_detail/track_detail_bloc.dart';
import 'package:music_player/models/track.dart';
import 'package:music_player/repositories/track_repository.dart';

class TrackDetailsScreen extends StatelessWidget {
  final List<Track> trackList;
  final int initialIndex;

  const TrackDetailsScreen({
    super.key,
    required this.trackList,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrackDetailBloc(context.read<TrackRepository>()),
      child: _TrackDetailsView(
        trackList: trackList,
        initialIndex: initialIndex,
      ),
    );
  }
}

class _TrackDetailsView extends StatefulWidget {
  final List<Track> trackList;
  final int initialIndex;

  const _TrackDetailsView({
    required this.trackList,
    required this.initialIndex,
  });

  @override
  State<_TrackDetailsView> createState() => _TrackDetailsViewState();
}

class _TrackDetailsViewState extends State<_TrackDetailsView> {
  late int _currentIndex;
  late Track _currentTrack;
  final _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _currentTrack = widget.trackList[_currentIndex];
    _playCurrentTrack();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _playNext();
    });

    _fetchLyrics();
  }

  void _fetchLyrics() {
    context.read<TrackDetailBloc>().add(FetchLyrics(
          trackName: _currentTrack.title,
          artistName: _currentTrack.artist,
          albumName: _currentTrack.albumName,
          duration: _currentTrack.duration,
        ));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playCurrentTrack() {
    if (_currentTrack.preview.isNotEmpty) {
      _audioPlayer.play(UrlSource(_currentTrack.preview));
    }
  }

  void _handlePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      if (_currentTrack.preview.isNotEmpty) {
        _audioPlayer.resume();
      }
    }
  }

  void _playNext() {
    if (_currentIndex < widget.trackList.length - 1) {
      setState(() {
        _currentIndex++;
        _currentTrack = widget.trackList[_currentIndex];
        _position = Duration.zero;
        _duration = Duration.zero;
        _playCurrentTrack();
        _fetchLyrics();
      });
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentTrack = widget.trackList[_currentIndex];
        _position = Duration.zero;
        _duration = Duration.zero;
        _playCurrentTrack();
        _fetchLyrics();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lyrics_outlined, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _LyricsView(),
                backgroundColor: Colors.grey[900],
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _currentTrack.albumCover ?? '',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: Colors.grey[900]),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    _currentTrack.albumCover ?? '',
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.width * 0.7,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.music_note, size: 200, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _currentTrack.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _currentTrack.artist,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey[300]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Slider(
                  min: 0,
                  max: _duration.inSeconds.toDouble() + 1.0,
                  value: _position.inSeconds.toDouble(),
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await _audioPlayer.seek(position);
                    if (!_isPlaying) {
                      _audioPlayer.resume();
                    }
                  },
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey[600],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _position.toString().split('.').first,
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        _duration.toString().split('.').first,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous, size: 48),
                      color: Colors.white,
                      onPressed: _playPrevious,
                    ),
                    IconButton(
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 72,
                      ),
                      color: Colors.white,
                      onPressed: _handlePlayPause,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 48),
                      color: Colors.white,
                      onPressed: _playNext,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LyricsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackDetailBloc, TrackDetailState>(
      builder: (context, state) {
        if (state.status == TrackDetailStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.lyrics == null || (state.lyrics!.lyrics?.isEmpty ?? true)) {
          return const Center(
              child: Text('No lyrics found', style: TextStyle(color: Colors.white)));
        }
        if (state.lyrics!.instrumental) {
          return const Center(
              child: Text('Instrumental', style: TextStyle(color: Colors.white)));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            state.lyrics!.lyrics!,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
