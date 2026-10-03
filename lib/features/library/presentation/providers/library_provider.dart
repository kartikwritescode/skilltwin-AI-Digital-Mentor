import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/library_repository.dart';
import '../../data/repositories/library_repository_provider.dart';
import '../../../../core/models/resource.dart';
import '../../../../core/storage/storage_provider.dart';

class LibraryState {
  final List<Resource> allResources;
  final Set<String> savedResourceIds;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final ResourceType? typeFilter;
  final bool showOnlySaved;

  const LibraryState({
    this.allResources = const [],
    this.savedResourceIds = const {},
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.typeFilter,
    this.showOnlySaved = false,
  });

  /// Computed filtered resources list respecting search query, format type filter,
  /// and the "Saved" bookmark toggle.
  List<Resource> get filteredResources {
    var list = allResources;

    // 1. Saved / Bookmarked filter
    if (showOnlySaved) {
      list = list.where((r) => savedResourceIds.contains(r.id)).toList();
    }

    // 2. Resource type format filter
    if (typeFilter != null) {
      list = list.where((r) => r.type == typeFilter).toList();
    }

    // 3. Search query (title, extracted concepts, notes, synthesis metadata)
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      list = list.where((r) {
        final titleMatch = r.title.toLowerCase().contains(q);
        final conceptMatch =
            r.extractedConcepts.any((c) => c.toLowerCase().contains(q));
        final contentMatch = r.content?.toLowerCase().contains(q) ?? false;
        final notesMatch =
            r.generatedNotes?.toLowerCase().contains(q) ?? false;
        final mentorNoteMatch =
            r.synthesisMentorNote?.toLowerCase().contains(q) ?? false;
        return titleMatch ||
            conceptMatch ||
            contentMatch ||
            notesMatch ||
            mentorNoteMatch;
      }).toList();
    }

    return list;
  }

  /// Backward-compatibility getter for existing widgets and tests.
  List<Resource> get resources => filteredResources;

  // Counts for category badges
  int get totalCount => allResources.length;
  int get savedCount =>
      allResources.where((r) => savedResourceIds.contains(r.id)).length;
  int get pdfCount =>
      allResources.where((r) => r.type == ResourceType.pdf).length;
  int get linkCount => allResources
      .where((r) => r.type == ResourceType.link || r.type == ResourceType.url)
      .length;
  int get noteCount => allResources
      .where((r) => r.type == ResourceType.note || r.type == ResourceType.text)
      .length;

  bool isSaved(String id) => savedResourceIds.contains(id);

  LibraryState copyWith({
    List<Resource>? allResources,
    Set<String>? savedResourceIds,
    bool? isLoading,
    String? error,
    String? searchQuery,
    ResourceType? typeFilter,
    bool clearTypeFilter = false,
    bool? showOnlySaved,
  }) {
    return LibraryState(
      allResources: allResources ?? this.allResources,
      savedResourceIds: savedResourceIds ?? this.savedResourceIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      showOnlySaved: showOnlySaved ?? this.showOnlySaved,
    );
  }
}

final libraryProvider =
    StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return LibraryNotifier(repository, ref: ref);
});

class LibraryNotifier extends StateNotifier<LibraryState> {
  static const String _savedStorageKey = 'skilltwin_saved_resources';
  final LibraryRepository _repository;
  final Ref? _ref;

  LibraryNotifier(this._repository, {Ref? ref})
      : _ref = ref,
        super(const LibraryState()) {
    _initSavedFromStorage();
    loadResources();
  }

  void _initSavedFromStorage() {
    try {
      final prefs = _ref?.read(sharedPrefsProvider);
      final list = prefs?.getStringList(_savedStorageKey) ?? [];
      if (list.isNotEmpty) {
        state = state.copyWith(savedResourceIds: list.toSet());
      }
    } catch (_) {
      // Graceful fallback for test environments without sharedPrefsProvider
    }
  }

  void _persistSavedToStorage(Set<String> saved) {
    try {
      final prefs = _ref?.read(sharedPrefsProvider);
      prefs?.setStringList(_savedStorageKey, saved.toList());
    } catch (_) {
      // Graceful fallback
    }
  }

  Future<void> loadResources() async {
    // Only show full loading if we have no resources yet
    if (state.allResources.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }
    try {
      final resources = await _repository.getResources();
      state = state.copyWith(allResources: resources, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Toggles bookmark / saved status of a resource, updates shared state immediately,
  /// and persists it to local storage.
  Future<void> toggleSave(String id) async {
    final updated = Set<String>.from(state.savedResourceIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = state.copyWith(savedResourceIds: updated);
    _persistSavedToStorage(updated);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  void setTypeFilter(ResourceType? type) {
    state = state.copyWith(
      typeFilter: type,
      clearTypeFilter: type == null,
      showOnlySaved: false,
    );
  }

  void setShowOnlySaved(bool showOnlySaved) {
    state = state.copyWith(
      showOnlySaved: showOnlySaved,
      clearTypeFilter: showOnlySaved,
    );
  }

  void selectCategory(String category) {
    switch (category) {
      case 'Saved':
        setShowOnlySaved(true);
        break;
      case 'PDFs':
        setTypeFilter(ResourceType.pdf);
        break;
      case 'Links':
        setTypeFilter(ResourceType.link);
        break;
      case 'Notes':
        setTypeFilter(ResourceType.note);
        break;
      case 'All':
      default:
        state = state.copyWith(
          showOnlySaved: false,
          clearTypeFilter: true,
        );
        break;
    }
  }

  Future<Resource?> uploadPdf(File file, String title) async {
    try {
      final resource = await _repository.uploadPdf(file, title);
      final updated = [resource, ...state.allResources];
      state = state.copyWith(allResources: updated);
      return resource;
    } catch (e) {
      state = state.copyWith(error: "Upload failed: $e");
      return null;
    }
  }

  Future<Resource?> addLink(String url, String title) async {
    try {
      final resource = await _repository.addLink(url, title);
      final updated = [resource, ...state.allResources];
      state = state.copyWith(allResources: updated);
      return resource;
    } catch (e) {
      state = state.copyWith(error: "Adding link failed: $e");
      return null;
    }
  }

  Future<Resource?> createNote(String content, String title) async {
    try {
      final resource = await _repository.createNote(content, title);
      final updated = [resource, ...state.allResources];
      state = state.copyWith(allResources: updated);
      return resource;
    } catch (e) {
      state = state.copyWith(error: "Note creation failed: $e");
      return null;
    }
  }

  Future<void> deleteResource(String id) async {
    try {
      await _repository.deleteResource(id);
      final updatedResources =
          state.allResources.where((r) => r.id != id).toList();
      final updatedSaved = Set<String>.from(state.savedResourceIds)..remove(id);
      state = state.copyWith(
        allResources: updatedResources,
        savedResourceIds: updatedSaved,
      );
      _persistSavedToStorage(updatedSaved);
    } catch (e) {
      state = state.copyWith(error: "Deletion failed: $e");
    }
  }
}

final resourceDetailProvider =
    FutureProvider.family<Resource, String>((ref, id) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getResourceDetails(id);
});

final isResourceSavedProvider =
    Provider.family<bool, String>((ref, resourceId) {
  final libraryState = ref.watch(libraryProvider);
  return libraryState.isSaved(resourceId);
});
