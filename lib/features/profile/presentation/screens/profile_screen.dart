import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../data/repositories/profile_repository_provider.dart';
import '../../../../core/models/user.dart';
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
              _buildHeaderCard(context, ref, user, displayName, initial, email),
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
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (goal.progressPercent / 100).clamp(0.0, 1.0),
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryAccent),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${goal.progressPercent.toInt()}% Completed',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryAccent,
                            ),
                          ),
                          Text(
                            goal.targetBenchmark ?? 'Production Ready',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                loading: () => const SkillTwinCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (_, __) => SkillTwinCard(
                  padding: const EdgeInsets.all(16),
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
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Info',
                      subtitle: 'Name, daily focus & timezone',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                      onTap: () => _editPersonalInfo(context, ref, user),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildSettingsTile(
                      icon: Icons.access_time_rounded,
                      title: 'Daily Practice Target',
                      subtitle: '${user?.dailyMinutes ?? 30} minutes / day',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                      onTap: () => _editPersonalInfo(context, ref, user),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildSettingsTile(
                      icon: Icons.public_rounded,
                      title: 'Timezone',
                      subtitle: user?.timezone ?? 'Asia/Kolkata',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
                      onTap: () => _editPersonalInfo(context, ref, user),
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
    WidgetRef ref,
    User? user,
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
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Edit Profile',
                      onPressed: () => _editPersonalInfo(context, ref, user),
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

  void _editPersonalInfo(BuildContext context, WidgetRef ref, User? user) {
    if (user == null) return;
    HapticFeedback.lightImpact();

    final nameController = TextEditingController(text: user.displayName.isNotEmpty ? user.displayName : user.name);
    int selectedMinutes = user.dailyMinutes;
    final timezoneController = TextEditingController(text: user.timezone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Edit Personal Info & Targets',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Customize how SkillTwin addresses you and schedules your daily learning.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Full Name',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Daily Practice Target',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [15, 30, 45, 60].map((mins) {
                      final isSelected = selectedMinutes == mins;
                      return ChoiceChip(
                        label: Text('$mins mins'),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryAccent,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => selectedMinutes = mins);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Timezone',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: timezoneController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Asia/Kolkata',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        final newTz = timezoneController.text.trim();
                        if (newName.isEmpty) return;

                        final updated = user.copyWith(
                          name: newName,
                          displayName: newName,
                          dailyMinutes: selectedMinutes,
                          timezone: newTz.isNotEmpty ? newTz : user.timezone,
                        );

                        Navigator.pop(bottomSheetContext);
                        ref.read(authProvider.notifier).updateUser(updated);

                        try {
                          await ref.read(profileRepositoryProvider).updateProfile(updated);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (_) {
                          // Handled by fallback
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
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
