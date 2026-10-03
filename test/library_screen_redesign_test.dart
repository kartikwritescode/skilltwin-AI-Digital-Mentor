import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skilltwin/core/models/resource.dart';
import 'package:skilltwin/core/storage/storage_provider.dart';
import 'package:skilltwin/features/library/data/repositories/library_repository_provider.dart';
import 'package:skilltwin/features/library/domain/repositories/library_repository.dart';
import 'package:skilltwin/features/library/presentation/providers/library_provider.dart';
import 'package:skilltwin/features/library/presentation/screens/library_screen.dart';
import 'package:skilltwin/features/library/presentation/widgets/library_empty_view.dart';
import 'package:skilltwin/features/library/presentation/widgets/library_header_banner.dart';
import 'package:skilltwin/features/library/presentation/widgets/library_loading_view.dart';
import 'package:skilltwin/features/library/presentation/widgets/library_resource_card.dart';

class _FakeLibraryRepository implements LibraryRepository {
  List<Resource> items;

  _FakeLibraryRepository([List<Resource>? initial])
      : items = initial ??
            [
              Resource(
                id: 'res_1',
                title: 'Deep Learning Architectures',
                type: ResourceType.pdf,
                status: ResourceStatus.ready,
                mentorLabel: ResourceLabel.useNow,
                extractedConcepts: ['CNNs', 'Residual Connections'],
                createdAt: DateTime(2026, 9, 20),
              ),
              Resource(
                id: 'res_2',
                title: 'Riverpod State Management Guide',
                type: ResourceType.link,
                status: ResourceStatus.ready,
                mentorLabel: ResourceLabel.keep,
                extractedConcepts: ['Notifiers', 'AsyncValue'],
                createdAt: DateTime(2026, 9, 22),
              ),
              Resource(
                id: 'res_3',
                title: 'Backpropagation Intuition Note',
                type: ResourceType.note,
                status: ResourceStatus.ready,
                mentorLabel: ResourceLabel.reference,
                extractedConcepts: ['Chain Rule', 'Gradients'],
                createdAt: DateTime(2026, 9, 24),
              ),
            ];

  @override
  Future<List<Resource>> getResources({String? query}) async {
    if (query == null || query.isEmpty) return List.from(items);
    return items
        .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<Resource> uploadPdf(dynamic file, String title) async {
    final res = Resource(
      id: 'res_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      type: ResourceType.pdf,
      status: ResourceStatus.ready,
      createdAt: DateTime.now(),
    );
    items.insert(0, res);
    return res;
  }

  @override
  Future<Resource> addLink(String url, String title) async {
    final res = Resource(
      id: 'res_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      type: ResourceType.link,
      status: ResourceStatus.ready,
      createdAt: DateTime.now(),
    );
    items.insert(0, res);
    return res;
  }

  @override
  Future<Resource> createNote(String content, String title) async {
    final res = Resource(
      id: 'res_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      type: ResourceType.note,
      status: ResourceStatus.ready,
      content: content,
      createdAt: DateTime.now(),
    );
    items.insert(0, res);
    return res;
  }

  @override
  Future<void> deleteResource(String id) async {
    items.removeWhere((r) => r.id == id);
  }

  @override
  Future<Resource> getResourceDetails(String id) async {
    return items.firstWhere((r) => r.id == id);
  }
}

void main() {
  late SharedPreferences mockPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockPrefs = await SharedPreferences.getInstance();
  });

  group('LibraryState & LibraryNotifier Unit Tests', () {
    test('initial state loads and computes format category counts', () async {
      final repo = _FakeLibraryRepository();
      final container = ProviderContainer(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(repo),
          sharedPrefsProvider.overrideWithValue(mockPrefs),
        ],
      );
      addTearDown(container.dispose);

      // Wait for loadResources in notifier constructor
      await container.read(libraryProvider.notifier).loadResources();
      final state = container.read(libraryProvider);

      expect(state.allResources.length, 3);
      expect(state.totalCount, 3);
      expect(state.pdfCount, 1);
      expect(state.linkCount, 1);
      expect(state.noteCount, 1);
      expect(state.savedCount, 0);
    });

    test('bookmark saving updates shared state immediately and persists to storage', () async {
      final repo = _FakeLibraryRepository();
      final container = ProviderContainer(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(repo),
          sharedPrefsProvider.overrideWithValue(mockPrefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(libraryProvider.notifier);
      await notifier.loadResources();

      // Initial saved count is 0
      expect(container.read(libraryProvider).isSaved('res_1'), isFalse);
      expect(container.read(libraryProvider).savedCount, 0);

      // Save resource res_1
      await notifier.toggleSave('res_1');

      // Shared state immediately reflects saved state
      expect(container.read(libraryProvider).isSaved('res_1'), isTrue);
      expect(container.read(libraryProvider).savedCount, 1);

      // Check SharedPreferences persistence
      final savedInStorage = mockPrefs.getStringList('skilltwin_saved_resources');
      expect(savedInStorage, contains('res_1'));

      // Filter by saved only
      notifier.setShowOnlySaved(true);
      expect(container.read(libraryProvider).filteredResources.length, 1);
      expect(container.read(libraryProvider).filteredResources.first.id, 'res_1');

      // Untoggle bookmark
      await notifier.toggleSave('res_1');
      expect(container.read(libraryProvider).isSaved('res_1'), isFalse);
      expect(container.read(libraryProvider).savedCount, 0);
      expect(container.read(libraryProvider).filteredResources.length, 0);
    });

    test('search query filters resources instantly in-memory without full reload', () async {
      final repo = _FakeLibraryRepository();
      final container = ProviderContainer(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(repo),
          sharedPrefsProvider.overrideWithValue(mockPrefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(libraryProvider.notifier);
      await notifier.loadResources();

      // Search by title
      notifier.setSearchQuery('Riverpod');
      var filtered = container.read(libraryProvider).filteredResources;
      expect(filtered.length, 1);
      expect(filtered.first.title, contains('Riverpod'));

      // Search by extracted concept
      notifier.setSearchQuery('Residual Connections');
      filtered = container.read(libraryProvider).filteredResources;
      expect(filtered.length, 1);
      expect(filtered.first.title, contains('Deep Learning'));

      // Clear search
      notifier.clearSearch();
      expect(container.read(libraryProvider).filteredResources.length, 3);
    });

    test('resource deletion updates state immediately and cleans up saved bookmarks', () async {
      final repo = _FakeLibraryRepository();
      final container = ProviderContainer(
        overrides: [
          libraryRepositoryProvider.overrideWithValue(repo),
          sharedPrefsProvider.overrideWithValue(mockPrefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(libraryProvider.notifier);
      await notifier.loadResources();

      // Save res_2
      await notifier.toggleSave('res_2');
      expect(container.read(libraryProvider).isSaved('res_2'), isTrue);

      // Delete res_2
      await notifier.deleteResource('res_2');

      // State is immediately updated
      expect(container.read(libraryProvider).allResources.length, 2);
      expect(container.read(libraryProvider).isSaved('res_2'), isFalse);
      expect(container.read(libraryProvider).savedCount, 0);
    });
  });

  group('Library Contextual Empty States', () {
    testWidgets('LibraryEmptyView renders empty bookshelf state with curious mascot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibraryEmptyView(
              type: EmptyLibraryType.emptyLibrary,
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Your bookshelf is looking a little empty.'), findsOneWidget);
      expect(find.text('Add First Resource'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('LibraryEmptyView renders no saved resources state with study mascot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibraryEmptyView(
              type: EmptyLibraryType.noSaved,
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Nothing saved yet. Let\'s change that.'), findsOneWidget);
      expect(find.text('Browse All Resources'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('LibraryEmptyView renders no search results state with thinking mascot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibraryEmptyView(
              type: EmptyLibraryType.noSearchResults,
              searchQuery: 'Quantum Computing',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('No matching resources found'), findsOneWidget);
      expect(find.textContaining('Quantum Computing'), findsOneWidget);
      expect(find.text('Clear Search'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('Library Sub-Widgets Rendering', () {
    testWidgets('LibraryLoadingView renders animated mascot gif and text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LibraryLoadingView(),
          ),
        ),
      );

      expect(find.text('Loading your learning bookshelf...'), findsOneWidget);
      expect(find.text('Organizing synthesized notes, PDFs, and concepts'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
    });

    testWidgets('LibraryResourceCard renders format icon, tags, and bookmark toggle', (tester) async {
      final resource = Resource(
        id: 'r1',
        title: 'Deep Learning Primitives',
        type: ResourceType.pdf,
        status: ResourceStatus.ready,
        mentorLabel: ResourceLabel.useNow,
        extractedConcepts: ['Tensors', 'Backprop'],
        createdAt: DateTime(2026, 9, 21),
      );

      bool toggleCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibraryResourceCard(
              resource: resource,
              isSaved: false,
              onToggleSave: () => toggleCalled = true,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Deep Learning Primitives'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('USE NOW'), findsOneWidget);
      expect(find.text('Tensors'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);

      // Tap bookmark
      await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
      expect(toggleCalled, isTrue);
    });

    testWidgets('LibraryHeaderBanner renders bookshelf branding and mentor recommendation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LibraryHeaderBanner(
              guidance: 'Prioritize Neural Network Foundations before afternoon session.',
            ),
          ),
        ),
      );

      expect(find.text('SMART LEARNING BOOKSHELF'), findsOneWidget);
      expect(find.text('PRIORITIZED FOCUS'), findsOneWidget);
      expect(find.textContaining('Neural Network Foundations'), findsOneWidget);
    });
  });

  group('LibraryScreen Full Integration & Reactivity', () {
    testWidgets('renders all resources, category tabs with counts, and allows search filtering', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = _FakeLibraryRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(mockPrefs),
            libraryRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Header title
      expect(find.text('Knowledge Library'), findsOneWidget);

      // Filter chips with badges
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('PDFs'), findsOneWidget);
      expect(find.text('Links'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);

      // All 3 mock resources rendered
      expect(find.text('Deep Learning Architectures'), findsOneWidget);
      expect(find.text('Riverpod State Management Guide'), findsOneWidget);
      expect(find.text('Backpropagation Intuition Note'), findsOneWidget);

      // Search for "Riverpod"
      await tester.enterText(find.byType(TextField), 'Riverpod');
      await tester.pumpAndSettle();

      expect(find.text('Riverpod State Management Guide'), findsOneWidget);
      expect(find.text('Deep Learning Architectures'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Deep Learning Architectures'), findsOneWidget);
      expect(find.text('Riverpod State Management Guide'), findsOneWidget);
    });

    testWidgets('switching to Saved tab shows contextual empty state when no items are saved', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = _FakeLibraryRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(mockPrefs),
            libraryRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap 'Saved' tab
      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();

      // Should show contextual empty saved view
      expect(find.text('Nothing saved yet. Let\'s change that.'), findsOneWidget);
      expect(find.text('Browse All Resources'), findsOneWidget);

      // Tap Browse All Resources to return to All
      await tester.tap(find.text('Browse All Resources'));
      await tester.pumpAndSettle();

      expect(find.text('Deep Learning Architectures'), findsOneWidget);
    });

    testWidgets('responsive layout renders without overflow on narrow 320px screen', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = _FakeLibraryRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(mockPrefs),
            libraryRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: LibraryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Knowledge Library'), findsOneWidget);
      expect(find.byType(LibraryResourceCard), findsWidgets);
    });
  });
}
