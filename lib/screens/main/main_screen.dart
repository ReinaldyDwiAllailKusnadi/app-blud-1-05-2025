import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';
import '../wisata/destination_list_screen.dart';
import '../recommendation/recommendation_screen.dart';
import '../jadwal/schedule_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onNavigateToSchedule() {
    setState(() {
      _currentIndex = 3; // Adjusted index (Home:0, Destinasi:1, Rekomendasi:2, Jadwal:3, Profile:4)
    });
  }

  void _onNavigateToRecommendation() {
    setState(() {
      _currentIndex = 2; // Index for RecommendationScreen
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onSeeAllSchedule: _onNavigateToSchedule,
        onGoToRecommendation: _onNavigateToRecommendation,
      ),
      const DestinationListScreen(),
      const RecommendationScreen(),
      const ScheduleScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.navBlue,
        unselectedItemColor: AppTheme.navUnselected,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Destinasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_rounded),
            label: 'Rekomendasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
