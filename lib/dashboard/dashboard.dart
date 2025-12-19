import 'package:ap_ui/auth/bloc/auth_bloc.dart';
import 'package:ap_ui/auth/bloc/auth_event.dart';
import 'package:ap_ui/auth/screen/login_page.dart';
import 'package:ap_ui/shared/constant/colors.dart';
import 'package:flutter/material.dart';

import 'package:ap_ui/auth/bloc/auth.dart';
import 'package:ap_ui/auth/screen/login_page.dart';
import 'package:ap_ui/shared/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // 🔴 Logout logic
  void _logout() {
    context.read<AuthBloc>().add(LogoutEvent());

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // 🔴 Confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text("Dashboard", style: TextStyle(color: whiteColor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: whiteColor),
            tooltip: "Logout",
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.80,
          children: const [
            _DashboardCard(
              title: "Total Customers",
              value: "120",
              icon: Icons.people,
              color: Color(0xFF66BB6A),
            ),
            _DashboardCard(
              title: "Total Staff",
              value: "15",
              icon: Icons.person_pin,
              color: Color(0xFF43A047),
            ),
            _DashboardCard(
              title: "Assigned Customers",
              value: "98",
              icon: Icons.assignment_ind,
              color: Color(0xFF388E3C),
            ),
            _DashboardCard(
              title: "Milk Sold (L)",
              value: "2,340",
              icon: Icons.local_drink,
              color: Color(0xFF2E7D32),
            ),
            _DashboardCard(
              title: "Milk in Hand (L)",
              value: "760",
              icon: Icons.inventory,
              color: Color(0xFF1B5E20),
            ),
            _DashboardCard(
              title: "Profit Balance (₹)",
              value: "45,800",
              icon: Icons.account_balance_wallet,
              color: Color(0xFF4CAF50),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 28,
              child: Icon(icon, color: color, size: 28),
            ),

            const SizedBox(height: 12),

            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: title.length > 15 ? 12 : 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
