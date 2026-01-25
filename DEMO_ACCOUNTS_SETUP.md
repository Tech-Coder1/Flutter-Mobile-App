# Demo Accounts Setup Guide

This guide shows how to create demo user and admin accounts in your Firebase project.

## Demo Account Credentials

### Regular User Account
- **Email:** user@excelerate.com
- **Password:** Demo@12345
- **Name:** Demo User

### Admin Account
- **Email:** admin@excelerate.com
- **Password:** Admin@12345
- **Name:** Demo Admin

## Steps to Create Demo Accounts

### 1. Create Regular User Account

#### Via Firebase Console:
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select `excelerate-app-4b169` project
3. Go to **Authentication** → **Users** tab
4. Click **Add user**
5. Enter:
   - Email: `user@excelerate.com`
   - Password: `Demo@12345`
6. Click **Add user**

#### Via App (Easiest):
1. Open your Flutter app at `http://localhost:port`
2. Click **Sign up** button
3. Enter the following:
   - Full Name: `Demo User`
   - Email: `user@excelerate.com`
   - Password: `Demo@12345`
   - Confirm Password: `Demo@12345`
4. Click **Sign up**
5. You're now logged in as a regular user!

### 2. Create Admin Account

#### Step 1: Create the user in Firebase Authentication
- Use the same **Sign up** flow in the app:
  - Full Name: `Demo Admin`
  - Email: `admin@excelerate.com`
  - Password: `Admin@12345`

#### Step 2: Promote user to admin via Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select `excelerate-app-4b169` project
3. Go to **Firestore Database**
4. Create a new collection called `admins` (if not exists)
5. Click **Add document**
6. Set document ID to the admin user's UID:
   - You can find the UID in **Authentication** → **Users** → click the admin email
   - Copy the UID from the user details
7. Add the following fields:
   - Field: `adminId` | Type: String | Value: (paste the UID)
   - Field: `email` | Type: String | Value: `admin@excelerate.com`
   - Field: `role` | Type: String | Value: `admin`
   - Field: `createdAt` | Type: Timestamp | Value: (current time)
8. Click **Save**

### 3. Test the Accounts

#### Test Regular User Login:
1. Open the app (or refresh if already open)
2. Click **Login**
3. Enter:
   - Email: `user@excelerate.com`
   - Password: `Demo@12345`
4. You should see the **User Dashboard**
5. Navigate through Courses, Internships, Profile, etc.

#### Test Admin Login:
1. Click the **Admin Portal** button on login screen (or use the admin login link if available)
2. Enter:
   - Email: `admin@excelerate.com`
   - Password: `Admin@12345`
3. You should see the **Admin Dashboard**
4. View statistics and admin controls

## Verify Firestore Collections

Once you've created the demo accounts, verify the data in Firestore:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select `excelerate-app-4b169` project
3. Go to **Firestore Database**
4. You should see collections:
   - `users` → contains `user@excelerate.com` document
   - `admins` → contains `admin@excelerate.com` document

### Expected User Document Structure:
```json
{
  "userId": "USER_UID",
  "fullName": "Demo User",
  "email": "user@excelerate.com",
  "phoneNumber": "",
  "linkedInUrl": "",
  "profileImageUrl": "",
  "enrolledCourses": [],
  "certificatesCount": 0,
  "applicationsCount": 0,
  "createdAt": "2026-01-22T..."
}
```

### Expected Admin Document Structure:
```json
{
  "adminId": "ADMIN_UID",
  "email": "admin@excelerate.com",
  "role": "admin",
  "createdAt": "2026-01-22T..."
}
```

## Create Sample Data (Optional)

To make testing more realistic, add some sample courses and internships:

### Add a Sample Course:
1. In Firestore, go to **courses** collection (create if needed)
2. Click **Add document**
3. Set document ID to something like `course_001`
4. Add fields:
   - `courseId`: `course_001`
   - `title`: `Flutter Development Masterclass`
   - `duration`: `8 weeks`
   - `level`: `Beginner`
   - `description`: `Learn Flutter from scratch and build beautiful cross-platform apps`
   - `enrolledUsers`: `[]` (empty array)
   - `createdBy`: `demo_admin`
   - `createdAt`: (current timestamp)

### Add a Sample Internship:
1. In Firestore, go to **internships** collection (create if needed)
2. Click **Add document**
3. Set document ID to something like `internship_001`
4. Add fields:
   - `internshipId`: `internship_001`
   - `role`: `Flutter Developer`
   - `company`: `Tech Startup Inc.`
   - `location`: `San Francisco, CA`
   - `type`: `Remote`
   - `description`: `Join our team and build amazing mobile apps with Flutter`
   - `postedBy`: `demo_admin`
   - `postedAt`: (current timestamp)

## Troubleshooting

**Issue:** "User doesn't exist" when trying to login
- **Solution:** Make sure you created the user in Firebase Authentication first, OR used the Sign up flow in the app

**Issue:** Admin login fails
- **Solution:** Make sure you added the user to the `admins` collection in Firestore with the correct UID and `role: "admin"` field

**Issue:** User profile not showing data after login
- **Solution:** Wait a moment for Firestore to sync, then refresh the page

**Issue:** Cannot see courses/internships in the app
- **Solution:** Create sample data in the `courses` and `internships` collections following the instructions above

## Next Steps

After setting up demo accounts:
1. Test all features (enrollment, application submission, etc.)
2. Create more sample data for realistic testing
3. Invite other users to test
4. Deploy to production when ready
