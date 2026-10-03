import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_theme.dart';
import '../../core/widgets/mentor_twin_fab.dart';
import '../../core/widgets/skilltwin_background.dart';

class MainWrapper extends ConsumerWidget {
  final Widget child;

  const MainWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _calculateSelectedIndex(context);
    final String location = GoRouterState.of(context).uri.path;
    final bool isJourneyRoadmap = location == '/journey' || location == '/journey/';
    final bool isJourney = location.startsWith('/journey');

    return Scaffold(
      extendBody: true,
      body: isJourneyRoadmap ? child : SkillTwinBackground(child: child),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1.0,
                    ),
                  ),
                  child: NavigationBarTheme(
                    data: NavigationBarThemeData(
                      height: 74,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      indicatorColor: const Color(0xFF5B5FEF).withValues(alpha: 0.12),
                      indicatorShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      iconTheme: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return const IconThemeData(
                            color: Color(0xFF5B5FEF),
                            size: 25,
                          );
                        }
                        return const IconThemeData(
                          color: Color(0xFF64748B),
                          size: 23,
                        );
                      }),
                      labelTextStyle: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return const TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5B5FEF),
                            letterSpacing: 0.1,
                          );
                        }
                        return const TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.1,
                        );
                      }),
                    ),
                    child: NavigationBar(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (index) => _onItemTapped(index, context),
                      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home_rounded),
                          label: 'Home',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.map_outlined),
                          selectedIcon: Icon(Icons.map_rounded),
                          label: 'Journey',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.psychology_outlined),
                          selectedIcon: Icon(Icons.psychology_rounded),
                          label: 'Twin',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.library_books_outlined),
                          selectedIcon: Icon(Icons.library_books_rounded),
                          label: 'Library',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.person_outline_rounded),
                          selectedIcon: Icon(Icons.person_rounded),
                          label: 'Profile',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: isJourney
          ? null
          : MentorTwinFab(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/mentor');
              },
            ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location == '/') return 0;
    if (location.startsWith('/journey')) return 1;
    if (location.startsWith('/twin')) return 2;
    if (location.startsWith('/library')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    HapticFeedback.selectionClick();
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/journey');
        break;
      case 2:
        context.go('/twin');
        break;
      case 3:
        context.go('/library');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
