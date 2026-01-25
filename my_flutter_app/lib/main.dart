import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_signup_screen.dart';
import 'screens/user_dashboard.dart';
import 'screens/courses_screen.dart';
import 'screens/internships_screen.dart';
import 'screens/application_form.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_dashboard_new.dart';
import 'screens/admin_courses_screen.dart';
import 'screens/admin_internships_screen.dart';
import 'screens/admin_users_screen.dart';
import 'screens/admin_analytics_screen.dart';
import 'screens/admin_settings_screen.dart';
import 'screens/admin_application_review.dart';
import 'screens/course_detail_screen.dart';
import 'screens/user_support_tickets_screen.dart';
import 'screens/admin_support_tickets_screen.dart';
import 'screens/internship_detail_screen.dart';
import 'screens/user_feedback_screen.dart';
import 'screens/admin_feedback_screen.dart';
import 'models/course_model.dart';
import 'models/internship_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase initialization errors are non-fatal
    // App can still run without Firebase in development
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const ExcelerateApp());
}

class ExcelerateApp extends StatelessWidget {
  const ExcelerateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excelerate',
      theme: ThemeData(
        primaryColor: const Color(0xFF4169E1), // Soft royal blue
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4169E1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          color: Color(0xFFF8F9FA), // Light gray
          elevation: 2,
          shadowColor: Color(0x1A000000), // Subtle shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4169E1), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4169E1),
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF4169E1),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          shadowColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF4169E1),
          unselectedItemColor: Color(0xFF6B7280),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/admin_login': (context) => const AdminLoginScreen(),
        '/admin_signup': (context) => const AdminSignupScreen(),
        '/user_dashboard': (context) => const UserDashboard(),
        '/courses': (context) => const CoursesScreen(),
        '/internships': (context) => const InternshipsScreen(),
        '/application_form': (context) => const ApplicationForm(),
        '/profile': (context) => const ProfileScreen(),
        '/admin_dashboard': (context) => const AdminDashboardNew(),
        '/admin_courses': (context) => const AdminCoursesScreen(),
        '/admin_internships': (context) => const AdminInternshipsScreen(),
        '/admin_users': (context) => const AdminUsersScreen(),
        '/admin_analytics': (context) => const AdminAnalyticsScreen(),
        '/admin_settings': (context) => const AdminSettingsScreen(),
        '/admin_application_review': (context) =>
            const AdminApplicationReviewScreen(),
        '/course_detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is CourseModel) {
            return CourseDetailScreen(course: args);
          }
          return const Scaffold(body: Center(child: Text('No course found')));
        },
        '/internship_detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is InternshipModel) {
            return InternshipDetailScreen(internship: args);
          }
          return const Scaffold(
            body: Center(child: Text('No internship found')),
          );
        },
        '/user_support_tickets': (context) => const UserSupportTicketsScreen(),
        '/admin_support_tickets': (context) =>
            const AdminSupportTicketsScreen(),
        '/feedback': (context) => const UserFeedbackScreen(),
        '/admin_feedback': (context) => const AdminFeedbackScreen(),
      },
    );
  }
}
