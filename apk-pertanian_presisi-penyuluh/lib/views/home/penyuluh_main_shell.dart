import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../forum/forum_page.dart';
import '../home/commodity_selection_page.dart';
import '../profile/profile_page.dart';
import '../verification/verification_inbox_page.dart';
import '../widgets/onboarding_profile_dialog.dart';

class PenyuluhMainShell extends StatefulWidget {
  const PenyuluhMainShell({super.key});

  @override
  State<PenyuluhMainShell> createState() => _PenyuluhMainShellState();
}

class _PenyuluhMainShellState extends State<PenyuluhMainShell> {
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
    CommoditySelectionPage(),
    VerificationInboxPage(),
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
            icon: Icon(Icons.yard_outlined),
            selectedIcon: Icon(Icons.yard, color: AppColors.primary),
            label: 'Audit Lahan',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check, color: AppColors.primary),
            label: 'Verifikasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum, color: AppColors.primary),
            label: 'Forum Tani',
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
