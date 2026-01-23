# Excelerate - Career Growth Mobile App

A modern, professional Flutter mobile application designed to help users accelerate their career growth through learning and internships. Features role-based access for both learners and administrators, with comprehensive Firebase integration, resume management, and feedback systems.

## 🎯 Latest Updates (January 22, 2026)

### ✅ Major Features Added
- **Resume Upload & Management**: Users can upload resumes via FilePicker and store them in Firebase Storage
- **Autofill Functionality**: Name and phone number automatically populate from application form when resume is uploaded
- **User Feedback System**: Users can submit feedback with ratings, categories, and comments
- **Admin Feedback Review**: Admins can view, filter, and manage user feedback with status updates and admin notes
- **Admin Dashboard Analytics**: Real-time statistics with charts showing enrollment trends and application statuses
- **Course Detail Screen**: Individual course pages with enrollment tracking and interactive features
- **Internship Detail Screen**: Detailed internship pages with full application workflow
- **Support Ticket System**: User and admin support ticket management interface
- **Activity Logging**: Comprehensive activity tracking for all user actions
- **Application Tracking**: Admin application review system with status management

### 🔧 Technical Improvements
- **Fixed 55 Compilation Errors**: Resolved all critical syntax errors, type mismatches, and Stream/Future pattern issues
- **Firebase Integration**: Complete setup with Cloud Firestore, Authentication, and Storage
- **Proper Error Handling**: Replaced `print()` with `debugPrint()` throughout the codebase
- **Stream/Future Patterns**: Fixed incorrect Stream.then() patterns and async/await implementations
- **Type Safety**: Corrected all type mismatches and casting issues
- **Missing Parentheses**: Fixed syntax errors in courses_screen, internships_screen, and user_dashboard

## 📱 Overview

Excelerate is a comprehensive mobile application that connects learners with courses and internship opportunities. The app features a clean, modern UI with a blue-and-white theme, providing an intuitive experience for career development.

## 🚀 User Journey

### Learner Flow
1. **App Launch** → Login Screen (`/login`)
2. **Authentication** → Enter credentials and login
3. **Onboarding** → Post-login introduction (`/onboarding`)
4. **Dashboard** → Main interface with bottom navigation (`/user_dashboard`)
5. **Explore** → Courses, Internships, or Profile sections
6. **Resume Upload** → Upload and manage resume in profile
7. **Feedback** → Submit feedback to admins through feedback system

### Admin Flow
1. **App Launch** → Login Screen (`/login`)
2. **Admin Access** → Click "Log in as Administrator"
3. **Admin Login** → Separate admin authentication (`/admin_login`)
4. **Admin Dashboard** → Management interface with analytics (`/admin_dashboard`)
5. **Manage Content** → Review applications, feedback, and tickets

## ✨ Features

- **Role-Based Access**: Separate interfaces for learners and administrators
- **Course Management**: Browse, enroll in, and track progress on available courses
- **Internship Opportunities**: Apply for internships with detailed application forms
- **Resume Management**: Upload, store, and manage resumes with Firebase Storage
- **User Dashboard**: Personalized dashboard with progress tracking and statistics
- **Profile Management**: Complete user profile with learning history and resume
- **Feedback System**: Users can submit feedback; admins can review and respond
- **Admin Analytics**: Real-time dashboard with charts and enrollment trends
- **Support Tickets**: User and admin support ticket management system
- **Activity Logging**: Comprehensive tracking of user actions and interactions
- **Modern UI**: Clean design with soft shadows and rounded corners
- **Responsive Design**: Optimized for mobile, web, and desktop devices
- **Firebase Integration**: Cloud Firestore for data storage, Authentication, and Storage

## 🏗️ Architecture

### Tech Stack
- **Framework**: Flutter 3.38.7
- **Language**: Dart 3.10.7
- **UI Components**: Material Design 3
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **State Management**: StreamBuilder/FutureBuilder patterns
- **Navigation**: Named routes with bottom navigation
- **File Management**: FilePicker for resume uploads
- **Charts**: FL Chart for analytics visualization
- **Ratings**: Flutter Rating Bar for user feedback

### Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.15.2
  firebase_auth: ^5.7.0
  cloud_firestore: ^5.6.12
  firebase_storage: ^12.4.10
  file_picker: ^8.3.7
  fl_chart: ^0.65.0
  flutter_rating_bar: ^4.0.1
  smooth_page_indicator: ^1.2.1
  cupertino_icons: ^1.0.8
```

### Project Structure
```
lib/
├── main.dart                          # App entry point and theme configuration
├── firebase_options.dart              # Firebase configuration
├── screens/                           # All screen widgets
│   ├── onboarding_screen.dart        # Welcome/onboarding slides
│   ├── login_screen.dart             # User authentication
│   ├── signup_screen.dart            # User registration
│   ├── admin_login_screen.dart       # Admin authentication
│   ├── user_dashboard.dart           # Main dashboard with bottom nav
│   ├── courses_screen.dart           # Course listing and enrollment
│   ├── course_detail_screen.dart     # Individual course details
│   ├── internships_screen.dart       # Internship opportunities
│   ├── internship_detail_screen.dart # Individual internship details
│   ├── application_form.dart         # Internship/course application form
│   ├── profile_screen.dart           # User profile and resume management
│   ├── admin_dashboard.dart          # Admin management panel with analytics
│   ├── admin_application_review.dart # Admin application review interface
│   ├── user_feedback_screen.dart     # User feedback submission
│   ├── admin_feedback_screen.dart    # Admin feedback review and management
│   ├── user_support_tickets_screen.dart  # User support tickets
│   └── admin_support_tickets_screen.dart # Admin ticket management
├── models/                            # Data models
│   ├── user_model.dart               # User data structure
│   ├── course_model.dart             # Course data structure
│   ├── internship_model.dart         # Internship data structure
│   ├── application_model.dart        # Application with resume URL
│   ├── feedback_model.dart           # Feedback data structure
│   ├── ticket_model.dart             # Support ticket structure
│   ├── progress_model.dart           # Course progress tracking
│   ├── activity_log_model.dart       # Activity logging
│   ├── admin_statistics_model.dart   # Admin statistics data
│   ├── notification_model.dart       # Notification data
│   └── admin_model.dart              # Admin user data
├── services/                          # Business logic and Firebase integration
│   ├── auth_service.dart             # Authentication service
│   ├── user_service.dart             # User data management
│   ├── course_service.dart           # Course operations
│   ├── internship_service.dart       # Internship operations
│   ├── application_service.dart      # Application management with resume
│   ├── feedback_service.dart         # Feedback submission and retrieval
│   ├── ticket_service.dart           # Support ticket management
│   ├── admin_statistics_service.dart # Analytics and statistics
│   ├── admin_content_service.dart    # Admin content management
│   ├── progress_service.dart         # Progress tracking
│   ├── notification_service.dart     # Notification handling
│   └── user_service.dart             # User service layer
└── widgets/                           # Reusable UI components
```
│   ├── signup_screen.dart        # User registration
│   ├── admin_login_screen.dart   # Admin authentication
│   ├── user_dashboard.dart       # Main dashboard with bottom nav
│   ├── courses_screen.dart       # Course listing and enrollment
│   ├── internships_screen.dart   # Internship opportunities
│   ├── application_form.dart     # Internship application form
│   ├── profile_screen.dart       # User profile and settings
│   └── admin_dashboard.dart      # Admin management panel
└── widgets/                 # Reusable UI components
```

## 📱 Modules & Screens

### 1. Authentication Module
#### User Login Screen (`/login`)
- Email and password authentication
- "Forgot Password" functionality
- Link to user registration
- Access to admin login
- Form validation with error handling

#### User Registration Screen (`/signup`)
- Full name, email, password, confirm password
- Form validation and password matching
- Link back to login screen

#### Admin Login Screen (`/admin_login`)
- Shield icon for security indication
- Separate admin credentials
- Access to admin dashboard
- Return to learner login option

### 2. User Dashboard Module
#### Home Dashboard (`/user_dashboard`)
- Welcome message with username
- Notification icon with badge counter
- "Explore Opportunities" section
- Courses and Internships cards with counts
- Recent updates notification feed
- Bottom navigation bar

#### Bottom Navigation
- **Home**: Main dashboard
- **Courses**: Course catalog
- **Internships**: Internship listings
- **Profile**: User profile and settings

### 3. Learning Module
#### Courses Screen (`/courses`)
- List of available courses
- Course cards with:
  - Title and description
  - Duration information
  - Difficulty level badges (Beginner/Intermediate/Advanced)
  - "Enroll Now" buttons
- Back navigation to dashboard

#### Profile Screen (`/profile`)
- Large blue header with user avatar
- User information display
- "My Learning" section:
  - Certificates count
  - Applications count
- "Settings" section:
  - Account settings
  - Logout functionality

### 4. Career Module
#### Internships Screen (`/internships`)
- List of internship opportunities
- Internship cards with:
  - Job role and company
  - Location information
  - Work type badges (Remote/Hybrid/On-site)
  - "Apply Now" buttons

#### Application Form (`/application_form`)
- Comprehensive application form:
  - Full Name
  - Email
  - Phone Number
  - LinkedIn Profile URL
  - Skills & Experience (textarea)
- Form validation
- Success feedback on submission

### 5. Administration Module
#### Admin Dashboard (`/admin_dashboard`)
- Administrative overview
- Statistics cards:
  - Total users count
  - Courses count
  - Internships count
  - Applications count
- Quick action buttons:
  - Add new courses
  - Post internships
  - Manage users
  - View reports

### 6. Onboarding Module
#### Onboarding Screen (`/onboarding`)
- Post-login app introduction
- Feature overview slides
- Welcome message for new users
- "Explore App" navigation to dashboard

## 🎨 Design System

### Colors
- **Primary**: Soft Royal Blue (`#4169E1`)
- **Background**: White (`#FFFFFF`)
- **Cards**: Light Gray (`#F8F9FA`)
- **Text**: Dark Gray (`#1A1A1A`) / Medium Gray (`#6B7280`)
- **Accent**: Green (success), Red (errors), Orange (warnings)

### Typography
- **Headlines**: Bold, 24-32px
- **Body Text**: Regular, 14-16px
- **Labels**: Medium, 12-14px
- **Font Family**: System default (SF Pro/Inter style)

### Components
- **Cards**: Rounded corners (16px), subtle shadows
- **Buttons**: Rounded (12px), elevation-free
- **Inputs**: Light gray background, blue focus border
- **Icons**: Outlined style for consistency

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.7+)
- Dart SDK (3.0.0+)
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Tech-Coder1/Flutter-Mobile-App
   cd Flutter-Mobile-App/my_flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Available Commands
```bash
# Run on connected device
flutter run

# Run on specific device
flutter run -d chrome      # Web browser
flutter run -d macos       # macOS desktop

# Build for production
flutter build apk          # Android APK
flutter build ios          # iOS app
flutter build web          # Web build

# Code quality
flutter analyze            # Static analysis
flutter test               # Run tests
```

## 📸 Screenshots

The app includes comprehensive UI mockups showing all screens and features. Screenshots are available in the `screenshots/` folder:

### Authentication & Onboarding
- ![Login Screen](screenshots/login_screen.png)
- ![Signup Screen](screenshots/signup_screen.png)
- ![Admin Login](screenshots/admin_login_screen.png)
- ![Onboarding](screenshots/onboarding_screen.png)

### Main App Features
- ![Dashboard](screenshots/user_dashboard.png)
- ![Courses](screenshots/courses_screen.png)
- ![Internships](screenshots/internships_screen.png)
- ![Application Form](screenshots/application_form.png)

### User Management
- ![Profile](screenshots/profile_screen.png)
- ![Admin Dashboard](screenshots/admin_dashboard.png)

### App Flow Screenshots
- ![Complete User Journey](screenshots/user_journey_flow.png)
- ![Admin Panel Overview](screenshots/admin_overview.png)

*Note: Add your actual screenshots to the `screenshots/` folder and update the filenames accordingly.*

### 📱 How to Add Screenshots

1. **Run the app** in Chrome: `flutter run -d chrome`
2. **Navigate through all screens** and features
3. **Take screenshots** using your browser's screenshot tool or keyboard shortcuts
4. **Save images** to the `screenshots/` folder with descriptive names
5. **Update README** with correct filenames
6. **Commit and push** the new screenshots

**Recommended Screenshot Names:**
- `login_screen.png` - User login interface
- `onboarding_screen.png` - Post-login introduction
- `user_dashboard.png` - Main dashboard with navigation
- `courses_screen.png` - Course catalog
- `internships_screen.png` - Internship listings
- `application_form.png` - Internship application form
- `profile_screen.png` - User profile page
- `admin_login_screen.png` - Administrator login
- `admin_dashboard.png` - Admin management panel

## 🔧 Development

### Code Structure
- **Clean Architecture**: Separation of concerns
- **Reusable Components**: Modular widget design
- **Form Validation**: Comprehensive input validation
- **Navigation**: Named routes for scalability
- **State Management**: Ready for expansion (Provider/BLoC)

### Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  smooth_page_indicator: ^1.1.0
```

## 📋 Features in Detail

### User Experience
- **Intuitive Navigation**: Bottom navigation with clear icons
- **Form Validation**: Real-time feedback on input errors
- **Loading States**: Smooth transitions and feedback
- **Error Handling**: User-friendly error messages
- **Accessibility**: Proper contrast and touch targets

### Security Features
- **Input Validation**: Client-side validation for all forms
- **Password Requirements**: Secure password policies
- **Role-Based Access**: Separate admin and user interfaces
- **Session Management**: Proper logout functionality

### Performance
- **Optimized Widgets**: Efficient rendering
- **Memory Management**: Proper disposal of controllers
- **Fast Loading**: Lightweight design
- **Responsive UI**: Adapts to different screen sizes

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter best practices
- Use meaningful commit messages
- Test on multiple devices
- Maintain code documentation
- Follow the existing design system


## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for UI inspiration
- Open source community for tools and libraries

---

**Last Updated**: January 19, 2026
**Flutter Version**: 3.38.7
**Dart Version**: 3.10.7
