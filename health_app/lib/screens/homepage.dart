import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:health_app/screens/diseasesScreen.dart';
import 'package:health_app/screens/patientsScreen.dart';
import 'package:health_app/screens/predictionTestScreen.dart';
import 'package:health_app/screens/ophthalmology_prediction.dart';
import 'package:health_app/services/firebase_services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:health_app/main.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _firebaseService = FirebaseService();
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'AI Glaucoma Predictor',
      'subtitle': 'Input clinical data (IOP, Age, CDR) to predict risk.',
      'color': const Color(0xFF06B6D4),
      'image': 'lib/assets/images/banner3.jpg',
    },
    {
      'title': 'Intelligent Analytics',
      'subtitle': 'Manage your patients and review clinical records seamlessly.',
      'color': const Color(0xFFD1FAE5),
      'image': 'lib/assets/images/banner1.jpg',
    },
  ];

  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Ophthalmology CDSS',
      'description': 'Advanced Logistic Regression model for Glaucoma screening.',
      'icon': Icons.visibility_rounded,
      'color': const Color(0xFF06B6D4),
      'route': const OphthalmologyPredictionScreen(),
    },
    {
      'title': 'Symptom Analyzer',
      'description': 'Enter symptoms and get instant disease predictions.',
      'icon': Icons.online_prediction_rounded,
      'color': const Color(0xFFD1FAE5),
      'route': SymptomInputScreen(),
    },
    {
      'title': 'Prescription Transcripts',
      'description': 'Record and review doctor-patient voice prescriptions.',
      'icon': Icons.mic_rounded,
      'color': Colors.amberAccent,
      'route': const PatientListScreen(),
    },
  ];

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Decorative Orbs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF06B6D4).withOpacity(0.15),
                boxShadow: [BoxShadow(color: const Color(0xFF06B6D4).withOpacity(0.15), blurRadius: 100)],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.1, duration: 4.seconds),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder<String?>(
                      future: _firebaseService.getUserName(),
                      builder: (context, snapshot) {
                        final name = snapshot.data ?? 'User';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 16, 
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.white70
                              ),
                            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white,
                              ),
                            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                          ],
                        );
                      },
                    ),
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeNotifier,
                      builder: (context, currentMode, _) {
                        final isDark = currentMode == ThemeMode.dark;
                        return IconButton(
                          onPressed: () {
                            themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                          },
                          icon: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: isDark ? const Color(0xFFD1FAE5) : const Color(0xFF0284C7),
                            size: 28,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFF0284C7).withOpacity(0.1),
                            padding: const EdgeInsets.all(12),
                          ),
                        ).animate().fadeIn(delay: 300.ms).scale();
                      },
                    ),
                  ],
                ),
              ),

              // Swipeable Top Banner
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: _banners.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentBannerIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final banner = _banners[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(banner['image']),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.4),
                                    BlendMode.darken,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    banner['color'].withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    banner['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    banner['subtitle'],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms).scaleXY(begin: 0.9);
                  },
                ),
              ),

              // Pagination Dots
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _banners.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: index == _currentBannerIndex ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: index == _currentBannerIndex
                            ? const Color(0xFF06B6D4)
                            : Colors.white24,
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Text(
                  'Clinical Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),

              // Feature Cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _features.length,
                  itemBuilder: (context, index) {
                    final feature = _features[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => feature['route']),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white.withOpacity(0.05) 
                                    : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white.withOpacity(0.1) 
                                    : Colors.black.withOpacity(0.1),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: feature['color'].withOpacity(0.15),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: feature['color'].withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        feature['icon'],
                                        color: feature['color'],
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            feature['title'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            feature['description'],
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.white30 
                                        : Colors.black38,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: (600 + (100 * index)).ms).slideX(begin: 0.2);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
