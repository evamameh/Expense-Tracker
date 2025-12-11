// main_navigation.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/pages/home_page.dart';
import '../ui/pages/analytics_page.dart';
import '../ui/pages/budget_page.dart';
import '../ui/pages/settings_page.dart';
import '../ui/pages/add_expense_page.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int index = 0;

  final pages = const [
    HomePage(),
    AnalyticsPage(),
    SizedBox(), // empty page placeholder for FAB
    BudgetPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1C14),

      // -------------------------------
      // MAIN PAGE
      // -------------------------------
      body: pages[index],

      // -------------------------------
      // CENTER FLOATING ACTION BUTTON
      // -------------------------------
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 68,
        width: 68,
        child: FloatingActionButton(
          backgroundColor: Colors.greenAccent,
          elevation: 6,
          child: const Icon(Icons.add, size: 32, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddExpensePage()),
            );
          },
        ),
      ),

      // -------------------------------
      // BOTTOM APP BAR WITH NOTCH
      // -------------------------------
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: const Color(0xFF0B1C14),
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // HOME
              _navItem(
                icon: Icons.grid_view_rounded,
                label: "Home",
                active: index == 0,
                onTap: () => setState(() => index = 0),
              ),

              // REPORTS
              _navItem(
                icon: Icons.bar_chart_rounded,
                label: "Reports",
                active: index == 1,
                onTap: () => setState(() => index = 1),
              ),

              const SizedBox(width: 55), // space for FAB

              // BUDGET
              _navItem(
                icon: Icons.account_balance_wallet_rounded,
                label: "Budget",
                active: index == 3,
                onTap: () => setState(() => index = 3),
              ),

              // SETTINGS
              _navItem(
                icon: Icons.settings_rounded,
                label: "Settings",
                active: index == 4,
                onTap: () => setState(() => index = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------
  // NAVIGATION ICON WIDGET
  // -------------------------------
  Widget _navItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: active ? Colors.greenAccent : Colors.white54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.greenAccent : Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
