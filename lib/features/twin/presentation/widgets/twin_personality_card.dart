import 'package:flutter/material.dart';
import '../../../../core/models/home_dashboard.dart';
import '../../../../core/models/twin_dashboard.dart';
import '../../../../core/utils/mastery_format.dart';
import '../models/twin_companion_persona.dart';

/// Renders the "Learning Personality" section of the Twin screen.
/// Surfaces the computed cognitive archetype and four empirical dimensions:
/// Velocity, Consistency, Verified Mastery, and Retention Strength.
class TwinPersonalityCard extends StatelessWidget {
  final TwinDashboardData twinData;
  final HomeDashboardData? homeData;
  final TwinCompanionPersona persona;

  const TwinPersonalityCard({
    super.key,
    required this.twinData,
    this.homeData,
    required this.persona,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Velocity
    final velocityVal = twinData.learningVelocity > 0
        ? twinData.learningVelocity
        : (homeData != null && homeData!.topicsCompleted > 0
            ? (homeData!.topicsCompleted / 4.0).clamp(0.5, 5.0)
            : 1.0);
    final velocityText = '${velocityVal.toStringAsFixed(1)} /wk';

    // 2. Consistency
    final streakDays = twinData.consistencyStreak > 0
        ? twinData.consistencyStreak
        : (homeData?.streakDays ?? 0);
    final consistencyText = '$streakDays ${streakDays == 1 ? 'day' : 'days'}';

    // 3. Verified Mastery
    final masteryPct = twinData.overallMastery > 0
        ? twinData.overallMastery.toMasteryPercentage
        : ((homeData?.overallMastery ?? 0.0) * 100).toInt().clamp(0, 100);

    // 4. Retention Strength
    final retentionPct = twinData.knowledgeCoverage > 0
        ? (twinData.knowledgeCoverage * 100).toInt().clamp(10, 100)
        : (100 - (twinData.conceptsAtRisk.length * 15)).clamp(50, 100);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEARNING PERSONALITY',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6366F1),
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Cognitive traits & study instinct model',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Archetype Hero Highlight ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF8FAFC),
                  persona.statusColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    persona.archetypeIcon,
                    color: persona.statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        persona.archetypeTitle,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        persona.archetypeDescription,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF475569),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── 4 Cognitive Dimensions Grid ──
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.7,
            children: [
              _PersonalityDimensionTile(
                icon: Icons.speed_rounded,
                iconColor: const Color(0xFF0284C7),
                label: 'VELOCITY',
                value: velocityText,
                subtext: 'Pacing velocity',
              ),
              _PersonalityDimensionTile(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFEA580C),
                label: 'CONSISTENCY',
                value: consistencyText,
                subtext: 'Streak habit',
              ),
              _PersonalityDimensionTile(
                icon: Icons.verified_rounded,
                iconColor: const Color(0xFF059669),
                label: 'VERIFIED MASTERY',
                value: '$masteryPct%',
                subtext: 'Empirical proof',
              ),
              _PersonalityDimensionTile(
                icon: Icons.memory_rounded,
                iconColor: const Color(0xFF7C3AED),
                label: 'RETENTION',
                value: '$retentionPct%',
                subtext: 'Memory durability',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PersonalityDimensionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtext;

  const _PersonalityDimensionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 130,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(icon, size: 13, color: iconColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      subtext,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
