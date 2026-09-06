import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/library_repository.dart';
import '../../data/repositories/library_repository_provider.dart';
import '../../../../core/models/resource.dart';

class LibraryState {
  final List<Resource> resources;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final ResourceType? typeFilter;

  LibraryState({
    this.resources = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.typeFilter,
  });

  LibraryState copyWith({
    List<Resource>? resources,
    bool? isLoading,
    String? error,
    String? searchQuery,
    ResourceType? typeFilter,
    bool clearTypeFilter = false,
  }) {
    return LibraryState(
      resources: resources ?? this.resources,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
    );
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return LibraryNotifier(repository);
});

class LibraryNotifier extends StateNotifier<LibraryState> {
  final LibraryRepository _repository;

  LibraryNotifier(this._repository) : super(LibraryState()) {
    loadResources();
  }

  Future<void> loadResources() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final resources = await _repository.getResources(query: state.searchQuery);
      
      // Filter locally for mock simplicity, or pass to repository in real implementation
      var filtered = resources;
      if (state.typeFilter != null) {
        filtered = filtered.where((r) => r.type == state.typeFilter).toList();
      }
      
      state = state.copyWith(resources: filtered, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadResources();
  }

  void setTypeFilter(ResourceType? type) {
    if (type == null) {
      state = state.copyWith(clearTypeFilter: true);
    } else {
      state = state.copyWith(typeFilter: type);
    }
    loadResources();
  }

  Future<void> uploadPdf(File file, String title) async {
    try {
      await _repository.uploadPdf(file, title);
      await loadResources();
    } catch (e) {
      state = state.copyWith(error: "Upload failed: $e");
    }
  }

  Future<void> deleteResource(String id) async {
    try {
      await _repository.deleteResource(id);
      await loadResources();
    } catch (e) {
      state = state.copyWith(error: "Deletion failed: $e");
    }
  }
}

final resourceDetailProvider = FutureProvider.family<Resource, String>((ref, id) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getResourceDetails(id);
});
