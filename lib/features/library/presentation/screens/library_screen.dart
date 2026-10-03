import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../mentor/presentation/providers/mentor_recommendation_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/add_resource_bottom_sheet.dart';
import '../widgets/library_empty_view.dart';
import '../widgets/library_filter_chips.dart';
import '../widgets/library_header_banner.dart';
import '../widgets/library_resource_card.dart';
import '../widgets/library_search_bar.dart';
import '../../../../core/widgets/skilltwin_loading_view.dart';
import '../../../../core/widgets/skilltwin_transition_switcher.dart';
import '../../../../core/widgets/skilltwin_refresh_indicator.dart';
import '../../../../core/widgets/skilltwin_background.dart';
import '../../../../app/theme/app_theme.dart';

/// The redesigned SkillTwin Knowledge Library screen.
/// Implements a smart personal learning bookshelf powered by SkillTwin,
/// integrating contextual mascot states, instant reactive bookmarks,
/// and smooth 60 FPS lazy-rendered scrolling.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryProvider);
    final notifier = ref.read(libraryProvider.notifier);
    final libraryMentorGuidance = ref.watch(libraryMentorGuidanceProvider);
    final filtered = state.filteredResources;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Knowledge Library',
          style: AppTypography.headline,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Add Resource',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 20,
                color: Color(0xFF4F46E5),
              ),
            ),
            onPressed: () => AddResourceBottomSheet.show(context, notifier),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SkillTwinBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SkillTwinRefreshIndicator(
              message: 'SkillTwin is updating your bookshelf...',
              onRefresh: () async {
                await notifier.loadResources();
              },
              child: SkillTwinTransitionSwitcher(
                child: _buildBody(
                  context,
                  state: state,
                  notifier: notifier,
                  filtered: filtered,
                  guidance: libraryMentorGuidance,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required LibraryState state,
    required LibraryNotifier notifier,
    required List<dynamic> filtered,
    required String guidance,
  }) {
    // 1. Initial Asynchronous Loading View with Animated Mascot GIF
    if (state.isLoading && state.allResources.isEmpty) {
      return const SkillTwinLoadingView.fullScreen(
        key: ValueKey('library_loading'),
        message: 'SkillTwin is preparing your next step.',
        subMessage: 'Loading your learning bookshelf...',
      );
    }

    // 2. Error State View
    if (state.error != null && state.allResources.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load library: ${state.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => notifier.loadResources(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. High Performance CustomScrollView with Lazy SliverList
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        // ── Search, Filters, and Bookshelf Context ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                LibraryHeaderBanner(guidance: guidance),
                const SizedBox(height: 12),
                LibrarySearchBar(
                  notifier: notifier,
                  currentQuery: state.searchQuery,
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),

        // ── Horizontal Filter Categories ──
        SliverToBoxAdapter(
          child: LibraryFilterChips(state: state, notifier: notifier),
        ),

        // ── Results Summary Header ──
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.showOnlySaved
                      ? 'Saved Bookmarks'
                      : (state.typeFilter != null
                          ? '${state.typeFilter!.name} Resources'
                          : 'All Resources'),
                  style: AppTypography.supporting.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${filtered.length} ${filtered.length == 1 ? 'item' : 'items'}',
                  style: AppTypography.supporting,
                ),
              ],
            ),
          ),
        ),

        // ── Contextual Empty State or Lazy Resource List ──
        if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(context, state: state, notifier: notifier),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final resource = filtered[index];
                  final isSaved = state.isSaved(resource.id);

                  return LibraryResourceCard(
                    resource: resource,
                    isSaved: isSaved,
                    onToggleSave: () => notifier.toggleSave(resource.id),
                    onDelete: () => _confirmDelete(
                      context,
                      resourceId: resource.id,
                      resourceTitle: resource.title,
                      notifier: notifier,
                    ),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),

        SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.calculateBottomNavInset(context)),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required LibraryState state,
    required LibraryNotifier notifier,
  }) {
    if (state.showOnlySaved) {
      return LibraryEmptyView(
        type: EmptyLibraryType.noSaved,
        onAction: () => notifier.selectCategory('All'),
      );
    }

    if (state.searchQuery.trim().isNotEmpty) {
      return LibraryEmptyView(
        type: EmptyLibraryType.noSearchResults,
        searchQuery: state.searchQuery,
        onAction: () => notifier.clearSearch(),
      );
    }

    return LibraryEmptyView(
      type: EmptyLibraryType.emptyLibrary,
      onAction: () => AddResourceBottomSheet.show(context, notifier),
    );
  }

  void _confirmDelete(
    BuildContext context, {
    required String resourceId,
    required String resourceTitle,
    required LibraryNotifier notifier,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Resource?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: Text(
          'Are you sure you want to remove "$resourceTitle" from your bookshelf? Associated synthesized notes will also be removed.',
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              notifier.deleteResource(resourceId);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resource removed from bookshelf'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
