import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  final List<Map<String, String>> _slides = [
    {
      'title': 'Welcome to Excelerate!',
      'subtitle': 'Your journey to career excellence starts here',
      'icon': '🎯',
    },
    {
      'title': 'Learn & Grow',
      'subtitle': 'Access premium courses and skill-building content',
      'icon': '📚',
    },
    {
      'title': 'Find Internships',
      'subtitle': 'Discover and apply for exciting internship opportunities',
      'icon': '💼',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                // Page changed
              },
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                return _buildSlide(_slides[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: _slides.length,
                  effect: const WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: Color(0xFF4169E1),
                    dotColor: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/user_dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Explore App'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(Map<String, String> slide) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            slide['icon']!,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 40),
          Text(
            slide['title']!,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4169E1),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            slide['subtitle']!,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A1A),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}