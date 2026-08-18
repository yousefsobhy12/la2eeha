import 'package:go_router/go_router.dart';
import '../nav/app_shell.dart';
import '../../features/browse/presentation/views/home_view.dart';
import '../../features/favorites/presentation/views/favorites_view.dart';
import '../../features/more/presentation/views/more_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeView()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              builder: (context, state) => const MoreView(),
            ),
          ],
        ),
      ],
    ),
  ],
);
