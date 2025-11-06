import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:ap_ui/auth/repo/auth_repo.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await authRepository.login(event.phone, event.password);

      print('✅ Login result: $result');

      emit(
        LoginSuccess(
          message: result["message"],
          token: result["token"],
          user: result["user"],
        ),
      );
    } catch (error, stackTrace) {
      // Log the full error and stack trace for debugging
      print('❌ Login error: $error');
      print('🧱 StackTrace: $stackTrace');

      // Emit the actual backend or caught error message
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      try {
        final result = await authRepository.register(
          event.name,
          event.email,
          event.password,
          event.phone,
          event.role,
        );

        print('✅ Register result: $result');

        emit(
          RegisterSuccess(
            message: result["message"],
            token: result["token"],
            user: result["user"],
          ),
        );
      } catch (repoError) {
        print('⚠️ Error in authRepository.register(): $repoError');
        emit(AuthFailure("Registration failed: ${repoError.toString()}"));
      }
    } catch (e, stack) {
      // This catches *unexpected Bloc-level errors* (e.g., emit failures)
      print('🔥 Unexpected error in _onRegisterRequested: $e');
      print(stack);
      emit(AuthFailure(e.toString()));
    }
  }
}
