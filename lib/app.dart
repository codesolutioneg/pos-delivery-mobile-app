import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/l10n/l10n_x.dart';
import 'core/l10n/locale_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/orders/presentation/cubit/current_order_cubit.dart';
import 'features/orders/presentation/cubit/orders_list_cubit.dart';
import 'features/splash/presentation/splash_gate.dart';
import 'features/tracking/domain/repositories/tracking_repository.dart';

class DishFlowDeliveryApp extends StatefulWidget {
  const DishFlowDeliveryApp({super.key});

  @override
  State<DishFlowDeliveryApp> createState() => _DishFlowDeliveryAppState();
}

class _DishFlowDeliveryAppState extends State<DishFlowDeliveryApp> {
  late final AuthCubit _authCubit;
  late final CurrentOrderCubit _orderCubit;
  late final OrdersListCubit _ordersListCubit;
  late final LocaleCubit _localeCubit;
  late final SplashGate _splashGate;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = sl<AuthCubit>();
    _orderCubit = sl<CurrentOrderCubit>();
    _ordersListCubit = sl<OrdersListCubit>();
    _localeCubit = sl<LocaleCubit>();
    _splashGate = SplashGate();
    _router = createAppRouter(_authCubit, _splashGate);
    // Subscribe before bootstrap so the first settled state is never missed.
    _authCubit.stream.listen(_onAuthChanged);
    _authCubit.bootstrap();
  }

  void _onAuthChanged(AuthState state) {
    if (state is! AuthInitial && state is! AuthLoading) {
      _splashGate.markAuthSettled();
    }
    if (state is AuthAuthenticated) {
      _orderCubit.watch(driverUid: state.driver.id);
      _ordersListCubit.watch(driverUid: state.driver.id);
      sl<TrackingRepository>().start(driverUid: state.driver.id);
    } else if (state is AuthUnauthenticated) {
      sl<TrackingRepository>().stop();
    }
  }

  @override
  void dispose() {
    _authCubit.close();
    _orderCubit.close();
    _ordersListCubit.close();
    _splashGate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _orderCubit),
        BlocProvider.value(value: _ordersListCubit),
        BlocProvider.value(value: _localeCubit),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp.router(
            onGenerateTitle: (context) =>
                context.l10n.appTitle(AppConfig.brandName),
            theme: AppTheme.light(),
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
