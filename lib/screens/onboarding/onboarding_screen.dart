import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
// Placeholder for the next screen (Input Screen)
import '../rewrite/input_screen.dart'; 

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text('SmartScribe AI', style: AppTextStyles.headline3),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (_) {},
                children: const [
                  OnboardingContent(
                    title: "Refine Your Voice with AI",
                    subtitle: "Transform your emails with professional tone adjustments in seconds. From casual to corporate, hit the right note every time.",
                    icon: Icons.edit_document,
                  ),
                   OnboardingContent(
                    title: "Compose with Confidence",
                    subtitle: "Never worry about the wrong tone again. Let AI polish your drafts into perfection effortlessly.",
                    icon: Icons.psychology_alt, // Represents AI/Thinking
                  ),
                   OnboardingContent(
                    title: "Save Time & Effort",
                    subtitle: "Why spend hours drafting? Get instant rewrites and focus on what matters most - your work.",
                    icon: Icons.rocket_launch,
                  ),
                ],
              ),
            ),
            
            // Indicators
            SmoothPageIndicator(
              controller: _pageController,
              count: 3,
              effect: const ExpandingDotsEffect(
                activeDotColor: AppColors.secondary,
                dotColor: Color(0xFFE0E0E0),
                dotHeight: 8,
                dotWidth: 8,
                spacing: 4,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.secondaryLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 77),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Rewrite Input Screen
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (_) => const RewriteInputScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(16),
                    )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Get Started", style: AppTextStyles.button),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            
            // Trusted By Text
            Text(
              "TRUSTED BY 50K+ PROFESSIONALS",
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main Card
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8F5E9), Color(0xFFE3F2FD)], // Light green to light blue
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 13),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 80,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 48),
          
          Text(
            title,
            style: AppTextStyles.headline1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
