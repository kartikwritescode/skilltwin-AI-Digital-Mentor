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
import '../../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../features/teach_mode/presentation/screens/teach_mode_screen.dart';
import '../../features/teach_mode/presentation/screens/teach_mode_report_screen.dart';
import '../../features/sessions/presentation/screens/revision_screen.dart';
import '../../features/sessions/presentation/screens/revision_retrieval_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/main_wrapper.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    navigatorKey: rootNavigatorKey,
    redirect: (context, state) {
      final status = authState.status;
      final isSplash = state.uri.path == '/splash';
      final isAuth = state.uri.path == '/login' || state.uri.path == '/signup';

      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return isSplash ? null : '/splash';
      }

      if (status == AuthStatus.unauthenticated || status == AuthStatus.error) {
        return isAuth ? null : '/login';
      }

      if (status == AuthStatus.onboardingRequired) {
        return '/onboarding';
      }

      if (status == AuthStatus.authenticated) {
        if (isSplash || isAuth || state.uri.path == '/onboarding') {
          return '/';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingFlowScreen(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => MainWrapper(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/journey',
            builder: (context, state) => const JourneyScreen(),
            routes: [
              GoRoute(
                path: 'concept/:conceptId',
                builder: (context, state) => ConceptDetailScreen(
                  conceptId: state.pathParameters['conceptId'] ?? '',
                ),
              ),
              GoRoute(
                path: 'topic/:topicId',
                builder: (context, state) => TopicDetailScreen(
                  topicId: state.pathParameters['topicId'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/twin',
            builder: (context, state) => const TwinScreen(),
            routes: [
              GoRoute(
                path: 'maintenance',
                builder: (context, state) => const KnowledgeMaintenanceScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
            routes: [
              GoRoute(
                path: 'resource/:resourceId',
                builder: (context, state) => ResourceDetailScreen(
                  resourceId: state.pathParameters['resourceId'] ?? '',
                ),
              ),
              GoRoute(
                path: 'note/:resourceId',
                builder: (context, state) => PersonalizedNoteScreen(
                  resourceId: state.pathParameters['resourceId'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/mentor',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MentorScreen(),
      ),
      GoRoute(
        path: '/session/:sessionId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId'] ?? '';
          return SessionScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/teach/:conceptId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => TeachModeScreen(
          conceptId: state.pathParameters['conceptId'],
        ),
      ),
      GoRoute(
        path: '/teach/report',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TeachModeReportScreen(),
      ),
      GoRoute(
        path: '/revision',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RevisionScreen(),
        routes: [
          GoRoute(
            path: 'retrieval/:conceptId',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => RevisionRetrievalScreen(
              conceptId: state.pathParameters['conceptId'] ?? '',
            ),
          ),
        ],
      ),
    ],
  );
});
