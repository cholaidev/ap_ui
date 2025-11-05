// auth_state.dart
sealed class AuthState {}

/// 💤 Default / initial state
class AuthInitial extends AuthState {}

/// ⏳ API loading
class AuthLoading extends AuthState {}

/// ✅ Login success
class LoginSuccess extends AuthState {
  final String message;
  final String token;
  final Map<String, dynamic> user;

  LoginSuccess({
    required this.message,
    required this.token,
    required this.user,
  });
}

/// 🧾 Register success
class RegisterSuccess extends AuthState {
  final String message;
  final String token;
  final Map<String, dynamic> user;

  RegisterSuccess({
    required this.message,
    required this.token,
    required this.user,
  });
}

/// ❌ Any failure (login or register)
class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}
