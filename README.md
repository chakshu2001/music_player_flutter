# Music Player

A Flutter music library app that can render and interact with 50,000+ tracks smoothly.

## How it Works

The app is built using the BLoC pattern for a clean separation of concerns.

- **Lazy Loading & Paging**: The app uses infinite scrolling with lazy loading. The `TrackListBloc` fetches tracks in pages of 50 from the Deezer API. The `LibraryScreen` uses a `ScrollController` to detect when the user is near the bottom of the list and triggers the `FetchMoreTracks` event to load the next page. This keeps memory usage stable and scrolling smooth.

- **Search**: The search functionality reuses the `TrackListBloc`. When a search query is entered, the `FetchTracks` event is dispatched, clearing the list and loading the first page of search results. Infinite scrolling works seamlessly within the search results.

## What would break at 100k items?

The current approach will still work at 100,000 items due to the lazy loading strategy. However, to further optimize:

- **UI Virtualization**: For even better performance, a custom `ScrollView` with a more aggressive widget recycling mechanism could be implemented.

- **Data Caching**: A local database cache (e.g., using `sqflite`) would reduce network requests and improve performance.

- **Search Debouncing**: To avoid excessive API calls while the user is typing, a debounce mechanism could be added to the search input.

- **Grouping + Sticky Headers**: For A-Z grouping, data would be pre-processed into a map. A custom `ScrollView` would then render the list with sticky headers for each group.
