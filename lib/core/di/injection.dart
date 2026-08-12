import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/orders/data/repositories/firestore_orders_repository.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/presentation/cubit/current_order_cubit.dart';
import '../../features/orders/presentation/cubit/orders_list_cubit.dart';
import '../../features/tracking/data/repositories/stub_tracking_repository.dart';
import '../../features/tracking/domain/repositories/tracking_repository.dart';
import '../l10n/locale_cubit.dart';
import '../network/dio_client.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton(() => LocaleCubit(prefs));

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerFactory(() => AuthCubit(sl(), sl()));

  sl.registerLazySingleton<OrdersRepository>(
    () => FirestoreOrdersRepository(),
  );
  sl.registerFactory(() => CurrentOrderCubit(sl()));
  sl.registerFactory(() => OrdersListCubit(sl()));

  sl.registerLazySingleton<TrackingRepository>(() => StubTrackingRepository());
}
