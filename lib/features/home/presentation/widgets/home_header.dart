import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/user.dart';
import '../../../../core/widgets/skilltwin_twin.dart';

/// Header for the Home Screen containing:
/// - LEFT: Personalized greeting with FIRST NAME ONLY + Learning Twin companion
/// - Dynamic time-of-day greeting (Morning, Afternoon, Evening)
/// - RIGHT: Streak Button (routes to /streak) and Notification Center Button
class HomeHeader extends StatelessWidget {
  final User? user;
  final int streakDays;
  final VoidCallback onNotificationTap;

  const HomeHeader({
    super.key,
    required this.user,
    required this.streakDays,
    required this.onNotificationTap,
  });

  /// Extracts the user's FIRST NAME ONLY from their actual name field.
  /// Never derives display name from email, username, UUID, or email prefix.
  /// Returns null if no valid human name is found.
  static String? extractFirstName(User? user) {
    if (user == null) return null;
    final email = user.email.toLowerCase().trim();

    // Check both name and displayName from the User model
    for (final raw in [user.name, user.displayName]) {
      final candidate = raw.trim();
      if (candidate.isEmpty) continue;

      // Reject email addresses
      if (candidate.contains('@')) continue;

      // Reject if candidate matches email prefix or full email
      if (email.isNotEmpty) {
        final emailPrefix = email.split('@').first;
        if (candidate.toLowerCase() == emailPrefix || candidate.toLowerCase() == email) {
          continue;
        }
      }

      // Reject UUID / hex strings
      if (RegExp(r'^[0-9a-fA-F-]{20,}$').hasMatch(candidate)) {
        continue;
      }

      // Extract the first word
      final words = candidate.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      if (words.isNotEmpty) {
        final first = words.first;
        if (first.length == 1) return first.toUpperCase();
        return first[0].toUpperCase() + first.substring(1);
      }
    }
    return null;
  }

  /// Determines time-based greeting: Good Morning, Good Afternoon, or Good Evening
  static String getDynamicGreeting({DateTime? now}) {
    final current = now ?? DateTime.now();
    final hour = current.hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstName = extractFirstName(user);
    final greeting = getDynamicGreeting();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Mascot Companion waving beside the greeting ──
          const SkillTwinTwin.waving(
            size: 42,
            isDecorative: true,
          ),
          const SizedBox(width: 10),

          // ── LEFT: Greeting & First Name ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  firstName != null ? '$greeting,' : greeting,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        firstName ?? 'Ready to learn?',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('👋', style: TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Another step closer to your goals!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ── RIGHT: Streak Pill + Notification Button ──
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Streak Pill (opens /streak)
              Semantics(
                button: true,
                label: '$streakDays day learning streak',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/streak');
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppTheme.cardBorder,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFFF7A00),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$streakDays',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 2. Notification Button
              Semantics(
                button: true,
                label: 'Notifications',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onNotificationTap();
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.cardBorder,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: AppTheme.textPrimary,
                            size: 19,
                          ),
                          // Notification dot indicator
                          Positioned(
                            top: 8,
                            right: 9,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppTheme.highlightPink,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
