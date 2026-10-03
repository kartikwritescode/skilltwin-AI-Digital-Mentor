import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_theme.dart';

enum EmptyLibraryType {
  emptyLibrary,
  noSaved,
  noSearchResults,
}

class LibraryEmptyView extends StatelessWidget {
  final EmptyLibraryType type;
  final String? searchQuery;
  final VoidCallback? onAction;

  const LibraryEmptyView({
    super.key,
    required this.type,
    this.searchQuery,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final String mascotAsset;
    final String title;
    final String subtitle;
    final String buttonLabel;
    final IconData buttonIcon;

    switch (type) {
      case EmptyLibraryType.noSaved:
        mascotAsset = 'assets/mascots/twin_journey_study.webp';
        title = 'Nothing saved yet. Let\'s change that.';
        subtitle =
            'Bookmark key reading materials, PDFs, and mentor synthesis notes to quickly find them on your bookshelf.';
        buttonLabel = 'Browse All Resources';
        buttonIcon = Icons.auto_stories_rounded;
        break;

      case EmptyLibraryType.noSearchResults:
        mascotAsset = 'assets/mascots/twin_mentor_thinking.webp';
        title = 'No matching resources found';
        final queryText = searchQuery != null && searchQuery!.isNotEmpty
            ? ' matching "$searchQuery"'
            : '';
        subtitle =
            'We couldn\'t find anything$queryText. Try different keywords or reset your filters.';
        buttonLabel = 'Clear Search';
        buttonIcon = Icons.clear_rounded;
        break;

      case EmptyLibraryType.emptyLibrary:
        mascotAsset = 'assets/mascots/twin_curious.webp';
        title = 'Your bookshelf is looking a little empty.';
        subtitle =
            'Add a PDF, documentation link, or personal study note to ground your cognitive model.';
        buttonLabel = 'Add First Resource';
        buttonIcon = Icons.add_circle_outline_rounded;
        break;
    }

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          // parent: BouncingScrollPhysics(), // all resources
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Contextual Mascot Looking Around / Studying ──
            SizedBox(
              height: 125,
              child: Image.asset(
                mascotAsset,
                height: 125,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.auto_stories_rounded,
                  size: 80,
                  color: AppTheme.primaryAccent,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Contextual Title ──
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 8),

            // ── Subtitle Description ──
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Primary Action Button ──
            if (onAction != null)
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onAction?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2238),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 1,
                ),
                icon: Icon(buttonIcon, size: 18),
                label: Text(
                  buttonLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            const SizedBox(height: 42,)
          ],
        ),
      ),
    );
  }
}
