import 'dart:io';
import 'package:ap_ui/auth/screen/splash_screen.dart';
import 'package:ap_ui/customer/bloc/history_bloc/customer_history_bloc.dart';
import 'package:ap_ui/employee/bloc/employee_bloc.dart';
import 'package:ap_ui/shared/theme.dart';
import 'package:ap_ui/supply/bloc/supply_bloc.dart';
import 'package:ap_ui/supply/cubit/supply_cubit_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

// 🧱 Import blocs, cubits, and screens
import 'package:ap_ui/auth/bloc/auth_bloc.dart';
import 'package:ap_ui/auth/repo/auth_repo.dart';
import 'package:ap_ui/auth/screen/login_page.dart';
import 'package:ap_ui/auth/screen/register_page.dart';
import 'package:ap_ui/dashboard/dashboard.dart';

// (add these imports as you create other features)
import 'package:ap_ui/customer/bloc/customer_bloc.dart';
// import 'package:ap_ui/vendor/bloc/vendor_bloc.dart';
// import 'package:ap_ui/supplies/bloc/supply_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
BuildContext get globalContext => navigatorKey.currentContext!;

// 🧩 Ignore SSL certificate issues for local API calls
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  // ✅ Load environment variables
  await dotenv.load(fileName: ".env");

  // ✅ Initialize HydratedBloc persistent storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  runApp(const MilkApp());
}

class MilkApp extends StatefulWidget {
  const MilkApp({super.key});

  @override
  State<MilkApp> createState() => _MilkAppState();
}

class _MilkAppState extends State<MilkApp> with WidgetsBindingObserver {
  final authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("🔄 App resumed — refreshing or syncing data...");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authRepository,
      child: MultiBlocProvider(
        providers: [
          /// 🔐 Auth BLoC
          BlocProvider(create: (context) => AuthBloc(authRepository)),

          /// 👥 Customer BLoC (fetch/add/edit customers)
          BlocProvider(create: (context) => CustomerBloc()),

          BlocProvider(create: (context) => EmployeeBloc()),

          BlocProvider(create: (context) => SupplyBloc()),

          BlocProvider(create: (context) => SupplyCubitCubit()),

          BlocProvider(create: (context) => CustomerHistoryBloc()),

          /// 🧾 Vendor BLoC
          // BlocProvider(create: (context) => VendorBloc()),

          // /// 🥛 Supply BLoC
          // BlocProvider(create: (context) => SupplyBloc()),
        ],
        child: MaterialApp(
          title: 'Milk Company',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/dashboard': (context) => const DashboardPage(),
          },
        ),
      ),
    );
  }
}
