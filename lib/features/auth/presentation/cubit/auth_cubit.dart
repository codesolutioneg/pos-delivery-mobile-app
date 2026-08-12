import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_state.dart';

/// Manages driver authentication session.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._loginUseCase, this._authRepository)
      : super(const AuthInitial());

  final LoginUseCase _loginUseCase;
  final AuthRepository _authRepository;

  Future<void> bootstrap() async {
    emit(const AuthLoading());
    final result = await _authRepository.restoreSession();
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (driver) {
        if (driver == null) {
          emit(const AuthUnauthenticated());
        } else {
          emit(AuthAuthenticated(driver));
        }
      },
    );
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(const AuthLoading());
    final result = await _loginUseCase(
      username: username,
      password: password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (driver) => emit(AuthAuthenticated(driver)),
    );
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
