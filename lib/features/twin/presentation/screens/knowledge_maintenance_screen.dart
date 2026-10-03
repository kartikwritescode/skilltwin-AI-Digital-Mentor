import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/skilltwin_loading_view.dart';
import '../../../../core/widgets/skilltwin_background.dart';
import '../../../../core/widgets/skilltwin_twin.dart';
import '../providers/knowledge_maintenance_provider.dart';
import '../../../../core/models/knowledge_maintenance_item.dart';
import '../../../../core/widgets/skilltwin_card.dart';

class KnowledgeMaintenanceScreen extends ConsumerWidget {
  const KnowledgeMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceState = ref.watch(knowledgeMaintenanceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkillTwinBackground(
        child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          maintenanceState.when(
            data: (items) {
              final grouped = _groupItems(items);
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildIntroHeader(context),
                    const SizedBox(height: 24),
                    ...grouped.entries.map((entry) => _MaintenanceSection(
                          status: entry.key,
                          items: entry.value,
                        )),
                    const SizedBox(height: 40),
                  ]),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: SkillTwinLoadingView(
                message: 'SkillTwin is preparing your next step.',
                subMessage: 'Auditing memory decay and neural connections...',
              ),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      backgroundColor: const Color(0xFFFAF9F6),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: const Text(
          'Knowledge Maintenance',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildIntroHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              SkillTwinTwin(asset: TwinAsset.focused, size: 40),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Personalized Intervention',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5, color: AppTheme.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Your mentor has identified concepts that need targeted repair or reinforcement based on your recent activity and retention risk.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Map<MaintenanceStatus, List<KnowledgeMaintenanceItem>> _groupItems(List<KnowledgeMaintenanceItem> items) {
    final Map<MaintenanceStatus, List<KnowledgeMaintenanceItem>> groups = {
      MaintenanceStatus.fix: [],
      MaintenanceStatus.revise: [],
      MaintenanceStatus.learnNext: [],
      MaintenanceStatus.keep: [],
      MaintenanceStatus.deprioritize: [],
    };
    for (final item in items) {
      groups[item.status]?.add(item);
    }
    groups.removeWhere((key, value) => value.isEmpty);
    return groups;
  }
}

class _MaintenanceSection extends StatelessWidget {
  final MaintenanceStatus status;
  final List<KnowledgeMaintenanceItem> items;

  const _MaintenanceSection({required this.status, required this.items});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16, top: 32),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: config.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                status.name.toUpperCase().replaceAll('NEXT', ' NEXT'),
                style: TextStyle(
                  color: config.color,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '(${items.length})',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        ...items.map((item) => _MaintenanceCard(item: item, statusColor: config.color, icon: config.icon)),
      ],
    );
  }

  _StatusConfig _getStatusConfig(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.keep:
        return _StatusConfig(color: AppTheme.positive, icon: Icons.verified_user_outlined);
      case MaintenanceStatus.revise:
        return _StatusConfig(color: AppTheme.primaryAccent, icon: Icons.history_rounded);
      case MaintenanceStatus.fix:
        return _StatusConfig(color: Colors.redAccent.shade700, icon: Icons.build_circle_outlined);
      case MaintenanceStatus.learnNext:
        return _StatusConfig(color: AppTheme.accentBlue, icon: Icons.rocket_launch_outlined);
      case MaintenanceStatus.deprioritize:
        return _StatusConfig(color: AppTheme.textMuted, icon: Icons.low_priority_rounded);
    }
  }
}

class _MaintenanceCard extends StatelessWidget {
  final KnowledgeMaintenanceItem item;
  final Color statusColor;
  final IconData icon;

  const _MaintenanceCard({required this.item, required this.statusColor, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SkillTwinCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.conceptTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      fontSize: 18,
                    ),
                  ),
                ),
                Icon(icon, color: statusColor.withOpacity(0.3), size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.reason,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      SkillTwinTwin(asset: TwinAsset.thinking, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'MENTOR GUIDANCE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.mentorRecommendation,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (item.ctaLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (item.ctaAction != null) {
                    if (item.ctaAction!.startsWith('note_')) {
                      final resourceId = item.ctaAction!.replaceFirst('note_', '');
                      context.push('/library/note/$resourceId');
                    } else if (item.ctaAction == 'revision' || item.ctaAction!.startsWith('rev_') || item.status == MaintenanceStatus.revise) {
                      context.push('/revision');
                    } else {
                      context.push('/session/${item.ctaAction}');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  item.ctaLabel!,
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;
  _StatusConfig({required this.color, required this.icon});
}
