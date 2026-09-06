import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../../core/widgets/skilltwin_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final activeGoalAsync = ref.watch(activeGoalProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUserInfo(context, user),
          const SizedBox(height: 24),
          _buildSectionHeader('Current Goal'),
          activeGoalAsync.when(
            data: (goal) => SkillTwinCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: goal.progress, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text('Edit Goal Details', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Learning Settings'),
          SkillTwinCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildListTile(Icons.timer_outlined, 'Daily Commitment', '1 hour'),
                const Divider(height: 1),
                _buildListTile(Icons.notifications_none, 'Notifications', 'On'),
                const Divider(height: 1),
                _buildListTile(Icons.dark_mode_outlined, 'Appearance', 'Light'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Account'),
          SkillTwinCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildListTile(Icons.security, 'Privacy & Data', null),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () => ref.read(authProvider.notifier).logout(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'SkillTwin v1.0.0',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, dynamic user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.orange.shade100,
          child: Text(
            user?.name.substring(0, 1).toUpperCase() ?? 'U',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.name ?? 'Learner',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          user?.email ?? '',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String? trailing) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: trailing != null 
        ? Text(trailing, style: const TextStyle(color: Colors.grey))
        : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
}
