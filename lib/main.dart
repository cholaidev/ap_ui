import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth/login_page.dart';
import 'auth/register_page.dart';
import 'auth/bloc/auth_bloc.dart';
import 'auth/repo/auth_repo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load environment variables before running the app
  await dotenv.load(fileName: ".env");

  final authRepository = AuthRepository();

  runApp(MilkApp(authRepository: authRepository));
}

class MilkApp extends StatelessWidget {
  final AuthRepository authRepository;

  const MilkApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => AuthBloc(authRepository))],
      child: MaterialApp(
        title: 'Milk Company',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF2E7D32),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: const Color(0xFFFFC107),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(fontSize: 16),
          ),
        ),
        home: const LoginPage(),
        routes: {'/register': (context) => const RegisterPage()},
      ),
    );
  }
}
