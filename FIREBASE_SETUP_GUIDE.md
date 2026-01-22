# Firebase Backend Setup Guide for Excelerate App

## Overview
This guide will help you set up Firebase for the Excelerate Flutter mobile app. The backend includes user authentication, course management, internship postings, applications, and real-time notifications.

## Prerequisites
- Firebase account (https://firebase.google.com)
- Flutter SDK installed
- Xcode (for iOS) / Android Studio (for Android)

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `excelerate-app`
4. Enable Google Analytics (optional)
5. Click **"Create project"**
6. Wait for project creation to complete

---

## Step 2: Add iOS App to Firebase

1. In Firebase Console, click **"Add app"** → **iOS**
2. Enter Bundle ID: `com.excelerate.app` (or your custom ID from Xcode)
3. Download `GoogleService-Info.plist`
4. In Xcode:
   - Right-click on Runner folder → Add Files
   - Select the downloaded `GoogleService-Info.plist`
   - Check "Copy items if needed" and select "Runner" target
5. Run `pod install` in `ios/` directory

---

## Step 3: Add Android App to Firebase

1. In Firebase Console, click **"Add app"** → **Android**
2. Enter package name from `android/app/build.gradle`: `com.excelerate.app`
3. Enter SHA-1 certificate fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   # Copy SHA1 from output
   ```
4. Download `google-services.json`
5. Place it in `android/app/` directory
6. In `android/build.gradle`, add:
   ```gradle
   classpath 'com.google.gms:google-services:4.3.10'
   ```
7. In `android/app/build.gradle`, add at the end:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

---

## Step 4: Add Web App to Firebase (Optional)

1. In Firebase Console, click **"Add app"** → **Web**
2. Enter app nickname: `excelerate-web`
3. Copy the config object
4. Store it for later use if needed

---

## Step 5: Set Up Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **"Create database"**
3. Choose region closest to you
4. **Start in Production mode** (we'll configure security rules)
5. Click **"Enable"**

### Create Collections

In Firestore, create the following collections by going to "Start collection":

1. **users** - Store user profiles
2. **admins** - Store admin accounts
3. **courses** - Store course information
4. **internships** - Store internship postings
5. **applications** - Store internship applications
6. **notifications** - Store user notifications

**Note**: You don't need to add any documents now. They'll be created automatically when users sign up or admins add content.

---

## Step 6: Set Up Security Rules

1. In Firebase Console, go to **Firestore Database** → **Rules**
2. Copy the content from `FIRESTORE_SECURITY_RULES.txt` file
3. Paste into the Rules editor
4. Click **"Publish"**

These rules ensure:
- Users can only read/modify their own data
- Only admins can create/modify courses and internships
- Users can see all courses and internships
- Applications are private to users and admins
- Notifications are private to users

---

## Step 7: Set Up Authentication

1. In Firebase Console, go to **Authentication**
2. Click **"Get started"**
3. Go to **Sign-in method** tab
4. Enable **Email/Password** authentication
5. Click **"Save"**

---

## Step 8: Create Admin Accounts

Since the app checks for admin status in the `admins` collection, you'll need to:

### Via Firebase Console:
1. Go to **Authentication** → **Users**
2. Click **"Add user"**
3. Create admin account (e.g., `admin@excelerate.com` / `password123`)
4. Note the UID of the created user

### Via Firestore:
1. Go to **Firestore Database** → **admins** collection
2. Click **"Add document"**
3. Document ID: (paste the UID from step above)
4. Add fields:
   - `email`: `admin@excelerate.com` (string)
   - `role`: `admin` (string)
   - `createdAt`: (server timestamp)
5. Click **"Save"**

Repeat for additional admin accounts.

---

## Step 9: Initialize Firebase in the App

The app is already configured with Firebase initialization in `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ExcelerateApp());
}
```

Make sure `pubspec.yaml` has the required Firebase packages:
```yaml
firebase_core: ^3.8.1
firebase_auth: ^5.3.4
cloud_firestore: ^5.5.2
firebase_storage: ^12.3.8
```

Run `flutter pub get` to install dependencies.

---

## Step 10: Test the App

1. Run the app:
   ```bash
   flutter run
   ```

2. **Test User Sign Up:**
   - Click "Sign up"
   - Enter name, email, password
   - Should create user and navigate to dashboard

3. **Test User Login:**
   - Click "Log In"
   - Use created credentials
   - Should navigate to user dashboard

4. **Test Admin Login:**
   - Click "Admin Access"
   - Use admin credentials created earlier
   - Should navigate to admin dashboard

5. **Test Courses:**
   - As admin: Add courses via admin dashboard (feature ready)
   - As user: View courses and enroll
   - Check if notifications appear

6. **Test Internships:**
   - As admin: Add internships
   - As user: View and apply for internships
   - Check applications in Firestore

---

## Database Schema Reference

### users
```
{
  fullName: string
  email: string
  phoneNumber: string (optional)
  linkedInUrl: string (optional)
  profileImageUrl: string (optional)
  enrolledCourses: array of courseIds
  certificatesCount: number
  applicationsCount: number
  createdAt: timestamp
}
```

### admins
```
{
  email: string
  role: string (e.g., "admin", "super_admin")
  createdAt: timestamp
}
```

### courses
```
{
  title: string
  duration: string (e.g., "8 weeks")
  level: string ("Beginner", "Intermediate", "Advanced")
  description: string
  enrolledUsers: array of userIds
  createdBy: adminId
  createdAt: timestamp
}
```

### internships
```
{
  role: string
  company: string
  location: string
  type: string ("Remote", "Hybrid", "On-site")
  description: string
  postedBy: adminId
  postedAt: timestamp
}
```

### applications
```
{
  userId: string
  internshipId: string
  fullName: string
  email: string
  phone: string
  linkedInUrl: string
  skillsExperience: string
  status: string ("pending", "accepted", "rejected")
  submittedAt: timestamp
}
```

### notifications
```
{
  userId: string
  title: string
  message: string
  type: string ("course", "internship", "application")
  isRead: boolean
  createdAt: timestamp
}
```

---

## Troubleshooting

### Build Errors on iOS
```bash
cd ios
rm -rf Pods Pod.lock
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### Build Errors on Android
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Firebase Connection Issues
- Ensure GoogleService-Info.plist (iOS) or google-services.json (Android) are in correct locations
- Check Firebase project ID matches in config files
- Verify security rules allow the operation

### Authentication Issues
- Check email/password are correct
- Verify user exists in Firebase Console
- For admin login, ensure admin document exists in `admins` collection

---

## Next Steps

1. **Add Cloud Storage** for profile pictures:
   ```dart
   firebase_storage: ^12.3.8
   ```

2. **Implement Push Notifications**:
   ```dart
   firebase_messaging: ^14.0.0
   ```

3. **Add Cloud Functions** for automated notifications, emails, and stats updates

4. **Set up Analytics**:
   ```dart
   firebase_analytics: ^latest
   ```

5. **Production Deployment**:
   - Use custom domain
   - Enable App Check
   - Set up monitoring alerts
   - Configure backup settings

---

## Support

For issues:
1. Check [Firebase Documentation](https://firebase.google.com/docs)
2. Review [FlutterFire Documentation](https://firebase.flutter.dev)
3. Check Firebase Console for error logs
