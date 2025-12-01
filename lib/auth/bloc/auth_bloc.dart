import 'dart:convert';
import 'package:ap_ui/auth/bloc/auth.dart';
import 'package:ap_ui/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:ap_ui/auth/repo/auth_repo.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    // on<AuthCheckStatus>(_onCheckStatus);
  }

  // Future<void> _onCheckStatus(
  //   AuthCheckStatus event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());
  //   final user = await authRepository.getSavedUser();

  //   if (user != null) {
  //     emit(Authenticated(user));
  //   } else {
  //     emit(Unauthenticated());
  //   }
  // }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await authRepository.login(event.phone, event.password);

      print('✅ Login result: $result');

      // Convert the map to a UserModel
      final user = UserModel.fromJson(result["user"]);

      // Store session globally
      final authManager = AuthManager();
      authManager.setSession(Authenticated(user, result["token"]));

      // Emit authenticated state
      emit(Authenticated(user, result["token"]));
    } catch (error, stackTrace) {
      print('❌ Login error: $error');
      print('🧱 StackTrace: $stackTrace');
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await authRepository.register(
        event.name,
        event.email,
        event.password,
        event.phone,
        event.role,
      );

      print('✅ Register result: $result');

      // Convert user map to model
      final user = UserModel.fromJson(result["user"]);
      final token = result["token"];

      // Store session globally
      final authManager = AuthManager();
      authManager.setSession(Authenticated(result["user"], token));

      // Emit Authenticated state
      emit(Authenticated(user, token));
    } catch (repoError, stack) {
      print('⚠️ Registration error: $repoError');
      print('🧱 Stack trace: $stack');
      emit(AuthFailure("Registration failed: ${repoError.toString()}"));
    }
  }

  // 🔹 Save current AuthState to storage
  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is Authenticated) {
      return {'user': state.user, 'token': state.token};
    }
    return null;
  }

  // 🔹 Restore saved AuthState from storage
  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      final user = UserModel.fromJson(json['user']);
      final token = json['token'];

      if (user != null && token != null) {
        final authManager = AuthManager();
        authManager.setSession(Authenticated(user, token));
        return Authenticated(user, token);
      }
      return Unauthenticated();
    } catch (e) {
      print('❌ Error restoring AuthState: $e');
      return null;
    }
  }
}
