import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'services/theme_service.dart';
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
import 'screens/inbox_screen.dart';
import 'models/course_model.dart';
import 'models/internship_model.dart';
import 'widgets/require_auth.dart';

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

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const ExcelerateApp(),
    ),
  );
}

class ExcelerateApp extends StatelessWidget {
  const ExcelerateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    
    return MaterialApp(
      title: 'Excelerate',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/admin_login': (context) => const AdminLoginScreen(),
        '/admin_signup': (context) => const AdminSignupScreen(),
        '/user_dashboard': (context) => const RequireAuth(child: UserDashboard()),
        '/courses': (context) => const RequireAuth(child: CoursesScreen()),
        '/internships': (context) => const RequireAuth(child: InternshipsScreen()),
        '/application_form': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final internshipArg = args is InternshipModel ? args : null;
          return RequireAuth(child: ApplicationForm(internship: internshipArg));
        },
        '/profile': (context) => const RequireAuth(child: ProfileScreen()),
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
            return RequireAuth(child: CourseDetailScreen(course: args));
          }
          return const Scaffold(body: Center(child: Text('No course found')));
        },
        '/internship_detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is InternshipModel) {
            return RequireAuth(child: InternshipDetailScreen(internship: args));
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
        '/inbox': (context) => const RequireAuth(child: InboxScreen()),
      },
    );
  }
}
