import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text("Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
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
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
