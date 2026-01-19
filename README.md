# Excelerate - Career Growth Mobile App

A modern, professional Flutter mobile application designed to help users accelerate their career growth through learning and internships. Features role-based access for both learners and administrators.

## 📱 Overview

Excelerate is a comprehensive mobile application that connects learners with courses and internship opportunities. The app features a clean, modern UI with a blue-and-white theme, providing an intuitive experience for career development.

## 🚀 User Journey

### Learner Flow
1. **App Launch** → Login Screen (`/login`)
2. **Authentication** → Enter credentials and login
3. **Onboarding** → Post-login introduction (`/onboarding`)
4. **Dashboard** → Main interface with bottom navigation (`/user_dashboard`)
5. **Explore** → Courses, Internships, or Profile sections

### Admin Flow
1. **App Launch** → Login Screen (`/login`)
2. **Admin Access** → Click "Log in as Administrator"
3. **Admin Login** → Separate admin authentication (`/admin_login`)
4. **Admin Dashboard** → Management interface (`/admin_dashboard`)

## ✨ Features

- **Role-Based Access**: Separate interfaces for learners and administrators
- **Course Management**: Browse and enroll in available courses
- **Internship Opportunities**: Apply for internships with detailed application forms
- **User Dashboard**: Personalized dashboard with progress tracking
- **Profile Management**: Complete user profile with learning history
- **Admin Panel**: Administrative tools for managing content
- **Modern UI**: Clean design with soft shadows and rounded corners
- **Responsive Design**: Optimized for mobile devices

## 🏗️ Architecture

### Tech Stack
- **Framework**: Flutter 3.38.7
- **Language**: Dart 3.10.7
- **UI Components**: Material Design 3
- **State Management**: Basic setState (expandable to Provider/BLoC)
- **Navigation**: Named routes with bottom navigation

### Project Structure
```
lib/
├── main.dart                 # App entry point and theme configuration
├── screens/                  # All screen widgets
│   ├── onboarding_screen.dart    # Welcome/onboarding slides
│   ├── login_screen.dart         # User authentication
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

The app includes comprehensive UI mockups showing all screens and features:

- ![Login Screen](Screenshot%202026-01-19%20at%209.06.33 AM.png)
- ![Dashboard](Screenshot%202026-01-19%20at%209.06.43 AM.png)
- ![Courses](Screenshot%202026-01-19%20at%209.06.51 AM.png)
- ![Internships](Screenshot%202026-01-19%20at%209.07.05 AM.png)
- ![Application Form](Screenshot%202026-01-19%20at%209.07.14 AM.png)
- ![Profile](Screenshot%202026-01-19%20at%209.07.18 AM.png)
- ![Admin Login](Screenshot%202026-01-19%20at%209.07.21 AM.png)
- ![Admin Dashboard](Screenshot%202026-01-19%20at%209.07.32 AM.png)

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
