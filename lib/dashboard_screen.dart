import 'package:flutter/material.dart';
import 'package:form_app_27_3_2026/login_screen.dart';
import 'package:form_app_27_3_2026/new_customer_screen.dart';
import 'package:form_app_27_3_2026/existing_customer_screen.dart';
import 'package:form_app_27_3_2026/todays_activity_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  final List<Map<String, dynamic>> _options = [
    {
      'title': 'New Customer',
      'subtitle': 'Open a new account',
      'icon': Icons.person_add_alt_1_rounded,
      'color': Color(0xFFFFC107),
    },
    {
      'title': 'Existing Customer',
      'subtitle': 'Update or view records',
      'icon': Icons.people_outline_rounded,
      'color': Color(0xFF4FC3F7),
    },
    {
      'title': 'Today\'s Activity',
      'subtitle': 'Review today\'s accounts',
      'icon': Icons.today_rounded,
      'color': Color(0xFF81C784),
    },
    {
      'title': 'Reports & More',
      'subtitle': 'Statements & analytics',
      'icon': Icons.bar_chart_rounded,
      'color': Color(0xFFCE93D8),
    },
  ];

  void _handleOptionTap(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NewCustomerScreen()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ExistingCustomerScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TodaysActivityScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_options[index]['title']} — Coming Soon')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(
        children: [
          // Background glowing circles
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A2F5A).withOpacity(0.8),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1B3A6B).withOpacity(0.5),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar: logout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Logout"),
                              content: const Text("Are you sure you want to logout?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Logout")),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('isLoggedIn'); // Or setBool('isLoggedIn', false)
                            if (!context.mounted) return;
                            
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout_rounded, color: Colors.white60, size: 20),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // Logo badge with glow
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFC107).withOpacity(0.15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFC107).withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC107),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("C°", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0A1628))),
                                  Text("360°", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0A1628))),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Brand title
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                            children: [
                              TextSpan(text: "AVS CoopSeva "),
                              TextSpan(
                                text: "360°",
                                style: TextStyle(color: Color(0xFFFFC107)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "COMPLETE CO-OPERATIVE BANKING SUITE",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Registered under Maharashtra Co-operative Societies Act, 1960",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(color: Colors.white38, fontSize: 12),
                            children: [
                              TextSpan(text: "RBI Licensed | DICGC Member | Powered by "),
                              TextSpan(
                                text: "IN-SO-TECH",
                                style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                        // Decorative divider
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Container(
                              width: 60,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC107),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),

                        // Option tiles (4)
                        ...List.generate(_options.length, (index) {
                          final opt = _options[index];
                          return GestureDetector(
                            onTap: () => _handleOptionTap(index),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F2040),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: (opt['color'] as Color).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(opt['icon'] as IconData, color: opt['color'] as Color, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          opt['title'] as String,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          opt['subtitle'] as String,
                                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
