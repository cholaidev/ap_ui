import 'package:ap_ui/customer/screen/customer_list_page.dart';
import 'package:ap_ui/supply/supply.dart';
import 'package:ap_ui/vendor/vendor_list.dart';
import 'package:flutter/material.dart';
import 'package:ap_ui/dashboard/dashboard.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    CustomerListPage(),
    VendorPage(),
    SuppliesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Customer"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Vendor"),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: "Supplies",
          ),
        ],
      ),
    );
  }
}
