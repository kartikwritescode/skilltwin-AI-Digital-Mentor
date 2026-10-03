import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'journey_theme_models.dart';

/// Floating, crisp module card positioned along the winding learning trail.
/// Features high-contrast typography, compact structure, clear progress indicator,
/// and subtle theme accents without excessive visual clutter.
class AdaptiveModuleCard extends StatelessWidget {
  final RoadmapModuleItem module;
  final VoidCallback? onTap;

  const AdaptiveModuleCard({
    super.key,
    required this.module,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = module.theme;
    final isLeft = module.isCardOnLeft;

    return Semantics(
      button: true,
      label: 'Module ${module.orderIndex + 1}: ${module.title}. '
          'Progress: ${module.completedCount} of ${module.totalCount} completed.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: theme.primary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.primary.withValues(alpha: 0.22),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Top Bar: Compact Module Badge + Subtle Affordance Arrow
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: isLeft
                            ? [
                                Flexible(
                                  child: _buildModuleBadge(
                                      theme, module.orderIndex + 1),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 11,
                                  color: theme.primary.withValues(alpha: 0.8),
                                ),
                              ]
                            : [
                                Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 11,
                                  color: theme.primary.withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: _buildModuleBadge(
                                      theme, module.orderIndex + 1),
                                ),
                              ],
                      ),
                      const SizedBox(height: 7),

                      // 2. High-contrast Module Title
                      Text(
                        module.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: isLeft ? TextAlign.left : TextAlign.right,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                          height: 1.25,
                        ),
                      ),

                      // 3. Compact Description / Context
                      if (module.description != null &&
                          module.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          module.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: isLeft ? TextAlign.left : TextAlign.right,
                          style: const TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF475569),
                            height: 1.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 9),

                      // 4. Progress bar & Completion Count (Breathable & Readable)
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: isLeft
                            ? [
                                Expanded(
                                  child: _buildProgressBar(theme, module.progress),
                                ),
                                const SizedBox(width: 8),
                                _buildProgressText(theme, module),
                              ]
                            : [
                                _buildProgressText(theme, module),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildProgressBar(theme, module.progress),
                                ),
                              ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleBadge(ModuleRegionTheme theme, int moduleNum) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.badgeBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'MODULE $moduleNum',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: theme.badgeText,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildProgressBar(ModuleRegionTheme theme, double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: 5,
        backgroundColor: const Color(0xFFE2E8F0),
        valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
      ),
    );
  }

  Widget _buildProgressText(ModuleRegionTheme theme, RoadmapModuleItem module) {
    return Text(
      '${module.completedCount} / ${module.totalCount}',
      style: const TextStyle(
        fontSize: 11.0,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1E293B),
        letterSpacing: 0.2,
      ),
    );
  }
}
