import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/journey/presentation/screens/journey_screen.dart';
import '../../features/journey/presentation/screens/topic_detail_screen.dart';
import '../../features/twin/presentation/screens/twin_screen.dart';
import '../../features/twin/presentation/screens/concept_detail_screen.dart';
import '../../features/twin/presentation/screens/knowledge_maintenance_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/library/presentation/screens/resource_detail_screen.dart';
import '../../features/library/presentation/screens/personalized_note_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/mentor/presentation/screens/mentor_screen.dart';
import '../../features/sessions/presentation/screens/session_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/intro_carousel_screen.dart';
import '../../features/auth/presentation/providers/intro_provider.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../features/teach_mode/presentation/screens/teach_mode_screen.dart';
import '../../features/teach_mode/presentation/screens/teach_mode_report_screen.dart';
import '../../features/sessions/presentation/screens/revision_screen.dart';
import '../../features/sessions/presentation/screens/revision_retrieval_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/streak/presentation/screens/streak_screen.dart';
import '../../features/main_wrapper.dart';
import '../../core/navigation/skilltwin_page_transitions.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final splashCompleteProvider = StateProvider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final isSplashComplete = ref.watch(splashCompleteProvider);
  final isIntroComplete = ref.watch(introCompletedProvider);

  return GoRouter(
    initialLocation: '/splash',
    navigatorKey: rootNavigatorKey,
    redirect: (context, state) {
      final status = authState.status;
      final isSplash = state.uri.path == '/splash';
      final isIntro = state.uri.path == '/intro';
      final isAuth = state.uri.path == '/login' || state.uri.path == '/signup';

      // Keep showing splash until initial entrance animation finishes
      // AND auth state is resolved beyond initial/loading.
      if (!isSplashComplete || status == AuthStatus.initial || status == AuthStatus.loading) {
        return isSplash ? null : '/splash';
      }

      // If user is authenticated, route directly to the main app
      if (status == AuthStatus.authenticated) {
        if (isSplash || isIntro || isAuth) {
          return '/';
        }
        return null;
      }

      // If user needs onboarding (e.g. initial profile setup)
      if (status == AuthStatus.onboardingRequired) {
        return state.uri.path == '/onboarding' ? null : '/onboarding';
      }

      // For unauthenticated users:
      if (status == AuthStatus.unauthenticated || status == AuthStatus.error) {
        // First-time users see the friendly introductory carousel
        if (!isIntroComplete) {
          return isIntro ? null : '/intro';
        }
        // Returning unauthenticated users go directly to login/signup
        return isAuth ? null : '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/intro',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const IntroCarouselScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => skillTwinTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => skillTwinTransitionPage(
          key: state.pageKey,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => skillTwinTransitionPage(
          key: state.pageKey,
          child: const OnboardingFlowScreen(),
        ),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => MainWrapper(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => skillTwinTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/journey',
            pageBuilder: (context, state) => skillTwinTransitionPage(
              key: state.pageKey,
              child: const JourneyScreen(),
            ),
            routes: [
              GoRoute(
                path: 'concept/:conceptId',
                pageBuilder: (context, state) => skillTwinTransitionPage(
                  key: state.pageKey,
                  child: ConceptDetailScreen(
                    conceptId: state.pathParameters['conceptId'] ?? '',
                  ),
                ),
              ),
              GoRoute(
                path: 'topic/:topicId',
                pageBuilder: (context, state) => skillTwinTransitionPage(
                  key: state.pageKey,
                  child: TopicDetailScreen(
                    topicId: state.pathParameters['topicId'] ?? '',
                  ),
                ),
              ),
              GoRoute(
                path: 'topics/:topicId',
                pageBuilder: (context, state) => skillTwinTransitionPage(
                  key: state.pageKey,
                  child: TopicDetailScreen(
                    topicId: state.pathParameters['topicId'] ?? '',
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/twin',
            pageBuilder: (context, state) => skillTwinTransitionPage(
              key: state.pageKey,
              child: const TwinScreen(),
            ),
            routes: [
              GoRoute(
                path: 'maintenance',
                pageBuilder: (context, state) => skillTwinTransitionPage(
                  key: state.pageKey,
                  child: const KnowledgeMaintenanceScreen(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/library',
            pageBuilder: (context, state) => skillTwinTransitionPage(
              key: state.pageKey,
              child: const LibraryScreen(),
            ),
            routes: [
              GoRoute(
                path: 'resource/:resourceId',
                pageBuilder: (context, state) => skillTwinTransitionPage(
                  key: state.pageKey,
                  child: ResourceDetailScreen(
                    resourceId: state.pathParameters['resourceId'] ?? '',
                  ),
                ),
              ),
              GoRoute(
                path: 'note/:resourceId',
                pageBuilder: (context, state) => skillTwinTransitionPage(
                  key: state.pageKey,
                  child: PersonalizedNoteScreen(
                    resourceId: state.pathParameters['resourceId'] ?? '',
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => skillTwinTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/streak',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => skillTwinTransitionPage(
          key: state.pageKey,
          child: const StreakScreen(),
        ),
      ),
      GoRoute(
        path: '/mentor',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => skillTwinTransitionPage(
          key: state.pageKey,
          child: const MentorScreen(),
        ),
      ),
      GoRoute(
        path: '/session/:sessionId',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final sessionId = state.pathParameters['sessionId'] ?? '';
          return skillTwinTransitionPage(
            key: state.pageKey,
            child: SessionScreen(sessionId: sessionId),
          );
        },
      ),
      GoRoute(
        path: '/teach/:conceptId',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => skillTwinTransitionPage(
          key: state.pageKey,
          child: TeachModeScreen(
            conceptId: state.pathParameters['conceptId'],
          ),
        ),
      ),
      GoRoute(
        path: '/teach/report',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => skillTwinTransitionPage(
          key: state.pageKey,
          child: const TeachModeReportScreen(),
        ),
      ),
      GoRoute(
        path: '/revision',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => skillTwinTransitionPage(
          key: state.pageKey,
          child: const RevisionScreen(),
        ),
        routes: [
          GoRoute(
            path: 'retrieval/:conceptId',
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (context, state) => skillTwinTransitionPage(
              key: state.pageKey,
              child: RevisionRetrievalScreen(
                conceptId: state.pathParameters['conceptId'] ?? '',
              ),
            ),
          ),
        ],
      ),
    ],
  );
});
