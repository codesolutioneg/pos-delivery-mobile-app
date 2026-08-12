import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/orders/domain/entities/delivery_order_entity.dart';
import '../../features/orders/presentation/pages/deliver_order_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/pickup_order_page.dart';
import '../../features/shell/presentation/pages/driver_shell_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/splash/presentation/splash_gate.dart';
import '../l10n/l10n_x.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/';
  static const orderDetailPath = '/orders/:id';
  static const pickup = '/pickup';
  static const deliver = '/deliver';

  static String orderDetail(String id) => '/orders/$id';
}

GoRouter createAppRouter(AuthCubit authCubit, SplashGate splashGate) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: Listenable.merge([_AuthRefresh(authCubit), splashGate]),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final auth = authCubit.state;

      // Animated splash owns the screen until it is done and auth is known.
      if (!splashGate.done) {
        return loc == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (auth is AuthInitial || auth is AuthLoading) {
        return loc == AppRoutes.splash ? AppRoutes.login : null;
      }

      final loggedIn = auth is AuthAuthenticated;

      if (!loggedIn && loc != AppRoutes.login) {
        return AppRoutes.login;
      }
      if (loggedIn && (loc == AppRoutes.login || loc == AppRoutes.splash)) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const DriverShellPage(),
      ),
      GoRoute(
        path: AppRoutes.orderDetailPath,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is DeliveryOrderEntity) {
            return OrderDetailPage(order: extra);
          }
          return Scaffold(
            body: Center(child: Text(context.l10n.orderNotFound)),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.pickup,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is DeliveryOrderEntity) {
            return PickupOrderPage(order: extra);
          }
          return Scaffold(
            body: Center(child: Text(context.l10n.orderNotFound)),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.deliver,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is DeliveryOrderEntity) {
            return DeliverOrderPage(order: extra);
          }
          return Scaffold(
            body: Center(child: Text(context.l10n.orderNotFound)),
          );
        },
      ),
    ],
  );
}

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(this._cubit) {
    _cubit.stream.listen((_) => notifyListeners());
  }

  final AuthCubit _cubit;
}
