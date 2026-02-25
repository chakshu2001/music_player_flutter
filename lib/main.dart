import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/bloc/track_detail/track_detail_bloc.dart';
import 'package:music_player/bloc/track_list/track_list_bloc.dart';
import 'package:music_player/repositories/track_repository.dart';
import 'package:music_player/screens/library_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => TrackRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TrackListBloc(
              context.read<TrackRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => TrackDetailBloc(
              context.read<TrackRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Music Player',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: const LibraryScreen(),
        ),
      ),
    );
  }
}
