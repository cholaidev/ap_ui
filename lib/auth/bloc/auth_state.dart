import 'package:ap_ui/models/user_model.dart';

/// 🔰 Base class for all Auth states
sealed class AuthState {}

/// 💤 Default / initial state
class AuthInitial extends AuthState {}

/// ⏳ Loading state (login/register/check)
class AuthLoading extends AuthState {}

/// ✅ Authenticated user state
class Authenticated extends AuthState {
  final UserModel user;
  final String token;

  Authenticated(this.user, this.token);
}

/// 🚪 Unauthenticated (user logged out or no saved session)
class Unauthenticated extends AuthState {}

/// ❌ Any failure (login/register/network/etc.)
class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

/// ✅ Login success (transitional UI feedback)
class LoginSuccess extends AuthState {
  final String message;
  final String token;
  final UserModel user;

  LoginSuccess({
    required this.message,
    required this.token,
    required this.user,
  });
}

/// 🧾 Register success (transitional UI feedback)
class RegisterSuccess extends AuthState {
  final String message;
  final String token;
  final UserModel user;

  RegisterSuccess({
    required this.message,
    required this.token,
    required this.user,
  });
}
