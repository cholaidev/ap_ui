import 'dart:async';
import 'package:ap_ui/auth/bloc/auth_state.dart';
import 'package:ap_ui/shared/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ap_ui/auth/bloc/auth_bloc.dart';
import 'package:ap_ui/auth/screen/login_page.dart';
import 'package:ap_ui/dashboard/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 1)); // splash delay
    final authBlocState = BlocProvider.of<AuthBloc>(context).state;
    final appSetup = await preInstall(context);

    if (appSetup) {
      if (authBlocState is Authenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Loading...")));
  }
}
