# Music Player Flutter App

This document provides a summary of the BLoC flow, design decisions, issues faced during development, and potential scalability challenges for the music player application.

## BLoC Flow Summary

The track details screen utilizes a `TrackDetailBloc` to manage the state of fetching song lyrics.

### Events

*   `FetchLyrics`: This event is triggered when a new track begins playing. It takes the track name, artist name, album name, and duration as parameters to request the corresponding lyrics from the repository.

### States

The `TrackDetailBloc` manages the following states:

*   `TrackDetailState`: The primary state object which contains:
    *   `TrackDetailStatus`: An enum representing the current status of the lyrics request.
        *   `initial`: The default state.
        *   `loading`: Indicates that a lyrics fetch is in progress.
        *   `success`: Indicates that the lyrics were fetched successfully.
        *   `failure`: Indicates that an error occurred while fetching lyrics.
    *   `lyrics`: A `Lyrics` model object containing the lyrics text and a boolean `instrumental` flag.
    *   `error`: An error message string, populated if the status is `failure`.

The UI (`_LyricsView`) listens to state changes from the `TrackDetailBloc` and rebuilds accordingly, showing a loading indicator, "No lyrics found" message, "Instrumental" text, or the lyrics themselves.

## Design Decisions

Here are three key design decisions made in the `track_details_screen.dart` file:

1.  **State Management with BLoC**: The decision was made to separate the business logic of fetching lyrics from the UI by using the BLoC pattern. A `TrackDetailBloc` is provided at the top of the widget tree (`TrackDetailsScreen`) and is made available to the `_LyricsView` modal bottom sheet using `BlocProvider.value`. This approach creates a decoupled and testable architecture, where the UI is only responsible for dispatching events and reacting to states.

2.  **Local UI State Management with `StatefulWidget`**: The management of the audio player, current track index, and playback state (`_isPlaying`, `_position`, `_duration`) is handled locally within the `_TrackDetailsViewState`. This is a deliberate choice to keep UI-specific concerns, like player controls and animations, separate from the business logic managed by BLoC. This prevents cluttering the `TrackDetailBloc` with logic that is only relevant to this specific screen.

3.  **Optimistic UI for Player Controls**: The UI for the play/pause button and the track progress slider updates immediately upon user interaction. For instance, when a user taps the pause button, the icon instantly changes to "play" (`_handlePlayPause`), providing immediate visual feedback. The actual state change in the `audioplayers` package happens asynchronously. This optimistic update strategy greatly improves the perceived responsiveness of the application.

## Issue Faced & Fix

*   **Issue:** When displaying the lyrics in the `showModalBottomSheet`, the lyrics data fetched in the main screen's context was not available to the `_LyricsView` widget within the bottom sheet. A new instance of the `TrackDetailBloc` would be created, losing the previously fetched state.

*   **Fix:** The problem was resolved by using `BlocProvider.value` when building the modal bottom sheet. Instead of creating a new `TrackDetailBloc`, `BlocProvider.value(value: BlocProvider.of<TrackDetailBloc>(context), ...)` was used. This ensures that the existing `TrackDetailBloc` instance from the parent `TrackDetailsScreen` widget is passed down into the bottom sheet's widget tree, allowing `_LyricsView` to access the current state, including the fetched lyrics.

## What Breaks at 100k Users?

Assuming 100,000 concurrent users:

*   **Lyrics API Rate Limiting & Costs:** The most significant point of failure would be the external lyrics API. The `_fetchLyrics` function is called every time a new track is played. With 100,000 users frequently skipping tracks, this would generate millions of API requests. The service would likely hit rate limits, leading to failed requests and a poor user experience. Furthermore, if the API is a paid service, the operational costs would become unsustainable.

    *   **Potential Solution:** Implement a caching layer (e.g., using a service like Redis or a local database on the backend) to store lyrics that have already been fetched. Before making a new API call, the system would first check this cache, dramatically reducing the number of requests to the external provider.

