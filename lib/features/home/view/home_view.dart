import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'home_tab.dart';
import '../../app_selection/view/app_selection_view.dart';
import '../../website_blocking/view/website_blocking_view.dart';
import '../../statistics/view/statistics_view.dart';
import '../../settings/view/settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const AppSelectionView(),
    const WebsiteBlockingView(),
    const StatisticsView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.accentPurple,
        unselectedItemColor: isDark ? Colors.white38 : Colors.black38,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.nights_stay),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'Apps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Websites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
