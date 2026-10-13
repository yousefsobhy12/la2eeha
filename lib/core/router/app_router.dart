import 'package:go_router/go_router.dart';
import '../nav/app_shell.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/auth/presentation/views/verify_email_view.dart';
import '../../features/auth/presentation/views/forgot_password_view.dart';
import '../../features/auth/presentation/views/reset_otp_view.dart';
import '../../features/auth/presentation/views/reset_password_view.dart';
import '../../features/browse/presentation/views/category_list_view.dart';
import '../../features/browse/presentation/views/home_view.dart';
import '../../features/browse/presentation/views/place_detail_view.dart';
import '../../features/browse/presentation/views/search_results_view.dart';
import '../../features/favorites/presentation/views/favorites_view.dart';
import '../../features/merchant/presentation/views/add_place_view.dart';
import '../../features/merchant/presentation/views/menu_pricing_view.dart';
import '../../features/merchant/presentation/views/pricing_args.dart';
import '../../features/merchant/presentation/views/sports_pricing_view.dart';
import '../../features/more/presentation/views/more_tab_view.dart';

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
              builder: (context, state) => const MoreTabView(),
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
    GoRoute(path: '/login', builder: (context, state) => const LoginView()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterView(),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) {
        final email = state.extra as String?;
        if (email == null) {
          return const RegisterView();
        }
        return VerifyEmailView(email: email);
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordView(),
    ),
    GoRoute(
      path: '/reset-otp',
      builder: (context, state) {
        final email = state.extra as String?;
        if (email == null) {
          return const ForgotPasswordView();
        }
        return ResetOtpView(email: email);
      },
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordView(),
    ),
    GoRoute(
      path: '/place/:id/menu',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final args = state.extra;
        if (args is PricingArgs) return MenuPricingView(args: args);
        return PlaceDetailView(placeId: id);
      },
    ),
    GoRoute(
      path: '/place/:id/pricing',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final args = state.extra;
        if (args is PricingArgs) return SportsPricingView(args: args);
        return PlaceDetailView(placeId: id);
      },
    ),
    GoRoute(
      path: '/add-place',
      builder: (context, state) => const AddPlaceView(),
    ),
    GoRoute(
      path: '/place/:id/edit',
      builder: (context, state) =>
          AddPlaceView(placeId: int.parse(state.pathParameters['id']!)),
    ),
  ],
);
