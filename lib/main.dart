import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:la2eeha/core/theme/cubit/theme_cubit.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'package:la2eeha/core/storage/local_storage_service.dart';
import 'package:la2eeha/features/favorites/presentation/cubit/favorites_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  // EXPERIMENT: liquid_tab_bar
  // Load the glass shader first so the bar can use the refraction tier, then
  // arm the frame governor (it only watches while the glass tier is on).
  await LiquidGlass.load();
  LiquidTabBarController.shared.armGovernor();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => FavoritesCubit(LocalStorageService())),
      ],
      child: const La2eeha(),
    ),
  );
}

class La2eeha extends StatelessWidget {
  const La2eeha({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) {
            return MaterialApp.router(
              title: 'La2eeha',
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter,
              locale: const Locale('ar'),
              supportedLocales: const [Locale('ar')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
            );
          },
        );
      },
    );
  }
}
