import 'package:go_router/go_router.dart';
import '../nav/app_shell.dart';
import '../../features/browse/presentation/views/category_list_view.dart';
import '../../features/browse/presentation/views/home_view.dart';
import '../../features/browse/presentation/views/place_detail_view.dart';
import '../../features/browse/presentation/views/search_results_view.dart';
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
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchResultsView(),
    ),
    GoRoute(
      path: '/places',
      builder: (context, state) => const CategoryListView(categoryId: null),
    ),
    GoRoute(
      path: '/category/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return CategoryListView(categoryId: id);
      },
    ),
    GoRoute(
      path: '/place/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return PlaceDetailView(placeId: id);
      },
    ),
  ],
);
