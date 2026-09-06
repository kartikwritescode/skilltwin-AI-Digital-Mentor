import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final activeGoalAsync = ref.watch(activeGoalProvider);
    final screenSize = MediaQuery.sizeOf(context);
    final isCompact = screenSize.width < 360;

    final displayName = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : (user?.name.isNotEmpty == true ? user!.name : 'Learner');
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'L';
    final email = user?.email ?? 'learner@skilltwin.ai';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 16 : 20,
              vertical: 12,
            ),
            children: [
              // ── 1. User Header Card ──
              _buildHeaderCard(context, displayName, initial, email),
              const SizedBox(height: 20),

              // ── 2. Learning Stats Row ──
              _buildStatsRow(context, user),
              const SizedBox(height: 24),

              // ── 3. Current Active Goal ──
              _buildSectionHeader('Current Focus'),
              activeGoalAsync.when(
                data: (goal) => SkillTwinCard(
                  padding: const EdgeInsets.all(20),
                  onTap: () => context.go('/journey'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.flag_rounded,
                              color: AppTheme.primaryAccent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                if (goal.description != null && goal.description!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    goal.description!,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: AppTheme.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: goal.progress,
                          minHeight: 7,
                          backgroundColor: AppTheme.primaryAccent.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryAccent),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level: ${(goal.currentLevel ?? 'beginner').toUpperCase()}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${(goal.progress * 100).toInt()}% completed',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: AppTheme.primaryAccent),
                  ),
                ),
                error: (_, __) => SkillTwinCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey),
                      const SizedBox(width: 12),
                      const Text(
                        'No active roadmap set yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.push('/onboarding'),
                        child: const Text('Set Goal'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── 4. Learning Preferences ──
              _buildSectionHeader('Preferences'),
              SkillTwinCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.access_time_rounded,
                      title: 'Daily Practice Target',
                      subtitle: '${user?.dailyMinutes ?? 30} minutes / day',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                      onTap: () {},
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildSettingsTile(
                      icon: Icons.public_rounded,
                      title: 'Timezone',
                      subtitle: user?.timezone ?? 'Asia/Kolkata',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                      onTap: () {},
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildSettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Daily Spaced Reminders',
                      subtitle: '9:00 AM daily',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── 5. Account & Security ──
              _buildSectionHeader('Account'),
              SkillTwinCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.shield_outlined,
                      title: 'Security & Supabase Auth',
                      subtitle: 'Protected with Bearer Token',
                      trailing: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      onTap: () {},
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildSettingsTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      titleColor: Colors.red.shade600,
                      iconColor: Colors.red.shade600,
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.red.shade400),
                      onTap: () => _confirmLogout(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // ── 6. App Version ──
              Center(
                child: Column(
                  children: [
                    Text(
                      'SkillTwin v1.0.0',
                      style: TextStyle(
                        color: AppTheme.textSecondary.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Decoupled Cognitive Architecture',
                      style: TextStyle(
                        color: AppTheme.textSecondary.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    String displayName,
    String initial,
    String email,
  ) {
    return SkillTwinCard(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryAccent, Color(0xFFFF8F00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryAccent.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'LEARNER',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryAccent,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, dynamic user) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Daily Goal',
            value: '${user?.dailyMinutes ?? 30}m',
            icon: Icons.bolt_rounded,
            color: const Color(0xFFFF6D00),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _StatCard(
            label: 'Twin State',
            value: 'Synced',
            icon: Icons.psychology_rounded,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _StatCard(
            label: 'Mode',
            value: 'Deliberate',
            icon: Icons.track_changes_rounded,
            color: Color(0xFF1565C0),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: AppTheme.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.textPrimary).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 19,
          color: iconColor ?? AppTheme.textPrimary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppTheme.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to log out of SkillTwin? Your progress will remain saved on Supabase.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SkillTwinCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
