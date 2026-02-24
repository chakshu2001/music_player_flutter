import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:music_player/models/lyrics.dart';
import 'package:music_player/models/track.dart';

class TrackRepository {
  final String _deezerBaseUrl = 'https://deezerdevs-deezer.p.rapidapi.com';
  final String _lrcLibBaseUrl = 'https://lrclib.net/api';

  Future<List<Track>> getTracks(String query, int index, int limit) async {
    try {
      final response = await http.get(
        Uri.parse('$_deezerBaseUrl/search?q=$query&index=$index&limit=$limit'),
        headers: {
          'X-RapidAPI-Host': 'deezerdevs-deezer.p.rapidapi.com',
          'X-RapidAPI-Key': 'e08e6d2be7mshbe5c26a13547420p125b85jsn7456cce21422',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final trackListData = data['data'];
        if (trackListData is List) {
          final tracks = trackListData.map((json) => Track.fromJson(json)).toList();
          return tracks;
        }
        return [];
      } else {
        throw Exception('Failed to load tracks');
      }
    } on SocketException {
      throw Exception('NO INTERNET CONNECTION');
    }
  }

  Future<Track> getTrackDetails(int trackId) async {
    try {
      final response = await http.get(
        Uri.parse('$_deezerBaseUrl/track/$trackId'),
        headers: {
          'X-RapidAPI-Host': 'deezerdevs-deezer.p.rapidapi.com',
          'X-RapidAPI-Key': 'e08e6d2be7mshbe5c26a13547420p125b85jsn7456cce21422',
        },
      );

      if (response.statusCode == 200) {
        return Track.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load track details');
      }
    } on SocketException {
      throw Exception('NO INTERNET CONNECTION');
    }
  }

  Future<Lyrics> getLyrics(String trackName, String artistName, String albumName, int duration) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_lrcLibBaseUrl/get-cached?track_name=$trackName&artist_name=$artistName&album_name=$albumName&duration=$duration'),
      );

      if (response.statusCode == 200) {
        return Lyrics.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load lyrics');
      }
    } on SocketException {
      throw Exception('NO INTERNET CONNECTION');
    }
  }
}
