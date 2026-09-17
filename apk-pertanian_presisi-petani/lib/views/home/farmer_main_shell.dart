import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../dashboard/soil_dashboard_page.dart';
import '../forum/forum_page.dart';
import '../profile/profile_page.dart';
import '../standar/standar_komoditas_page.dart';
import '../widgets/onboarding_profile_dialog.dart';

class FarmerMainShell extends StatefulWidget {
  const FarmerMainShell({super.key});

  @override
  State<FarmerMainShell> createState() => _FarmerMainShellState();
}

class _FarmerMainShellState extends State<FarmerMainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OnboardingProfileDialog.checkAndShow(context, onSaved: () {
        if (mounted) setState(() {});
      });
    });
  }

  final List<Widget> _pages = const [
    SoilDashboardPage(),
    StandarKomoditasPage(),
    ForumPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: AppColors.surfaceContainerLowest,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        elevation: 8,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sensors),
            selectedIcon: Icon(Icons.sensors, color: AppColors.primary),
            label: 'Monitor Tanah',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_outlined),
            selectedIcon: Icon(Icons.verified, color: AppColors.primary),
            label: 'Standar Komoditas',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum, color: AppColors.primary),
            label: 'Forum Petani',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
