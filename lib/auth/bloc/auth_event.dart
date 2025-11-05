// auth_event.dart
sealed class AuthEvent {
  const AuthEvent();
}

/// 🔐 Login Event
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});
}

/// 🧾 Register Event
class RegisterRequested extends AuthEvent {
  final String name;
  final String phone;
  final String email;
  final String password;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });
}

/// 🚪 Optional: Logout Event
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
