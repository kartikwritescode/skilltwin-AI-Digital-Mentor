import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/library_provider.dart';

class LibraryFilterChips extends StatelessWidget {
  final LibraryState state;
  final LibraryNotifier notifier;

  const LibraryFilterChips({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CategoryItem(
        label: 'All',
        count: state.totalCount,
        isSelected: !state.showOnlySaved && state.typeFilter == null,
      ),
      _CategoryItem(
        label: 'Saved',
        icon: Icons.bookmark_rounded,
        count: state.savedCount,
        isSelected: state.showOnlySaved,
      ),
      _CategoryItem(
        label: 'PDFs',
        icon: Icons.picture_as_pdf_rounded,
        count: state.pdfCount,
        isSelected: state.typeFilter != null && state.typeFilter!.name == 'pdf',
      ),
      _CategoryItem(
        label: 'Links',
        icon: Icons.link_rounded,
        count: state.linkCount,
        isSelected: state.typeFilter != null &&
            (state.typeFilter!.name == 'link' ||
                state.typeFilter!.name == 'url'),
      ),
      _CategoryItem(
        label: 'Notes',
        icon: Icons.description_rounded,
        count: state.noteCount,
        isSelected: state.typeFilter != null &&
            (state.typeFilter!.name == 'note' ||
                state.typeFilter!.name == 'text'),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: categories.map((cat) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.selectCategory(cat.label);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: cat.isSelected
                        ? const Color(0xFF1E2238)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: cat.isSelected
                          ? const Color(0xFF1E2238)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: cat.isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF1E2238)
                                  .withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cat.icon != null) ...[
                        Icon(
                          cat.icon,
                          size: 14,
                          color: cat.isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: cat.isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: cat.isSelected
                              ? Colors.white
                              : const Color(0xFF334155),
                        ),
                      ),
                      if (cat.count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: cat.isSelected
                                ? Colors.white.withValues(alpha: 0.2)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${cat.count}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: cat.isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryItem {
  final String label;
  final IconData? icon;
  final int count;
  final bool isSelected;

  _CategoryItem({
    required this.label,
    this.icon,
    required this.count,
    required this.isSelected,
  });
}
