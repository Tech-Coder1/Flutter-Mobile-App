# Excelerate - Career Growth Mobile App (Week 2)

**API Integration & Backend Connectivity Layer**

Building on Week 1's foundation, Week 2 focuses on API integration, backend connectivity patterns, and how the Flutter application communicates with Firebase backend services.

## 🎯 Week 2 Focus: API Architecture & How It Works

### What's New in Week 2
- **Complete API Documentation**: Firebase REST APIs and real-time listeners
- **Backend Connectivity Patterns**: Service layer architecture
- **Data Flow Architecture**: Request/Response cycles
- **Real-time Data Synchronization**: Firestore listeners
- **Error Handling & Retry Logic**: Robust API communication
- **Authentication Token Management**: Secure API calls

---

## 📡 API Architecture Overview

### Architecture Diagram
```
┌─────────────────────────────────────────────────┐
│        Flutter Mobile Application               │
├─────────────────────────────────────────────────┤
│  Screens → Models → Services (API Layer)        │
└──────────────────┬──────────────────────────────┘
                   │
        ┌──────────┼──────────┐
        │          │          │
    ┌───▼──┐  ┌───▼──┐  ┌───▼──┐
    │Auth  │  │Data  │  │Store │
    │API   │  │API   │  │API   │
    └───┬──┘  └───┬──┘  └───┬──┘
        │         │         │
        └─────────┼─────────┘
                  │
        ┌─────────▼─────────┐
        │   Firebase Backend │
        ├────────────────────┤
        │ • Authentication   │
        │ • Firestore DB     │
        │ • Cloud Storage    │
        └────────────────────┘
```

### Service Layer Structure
```
services/
├── auth_service.dart              # Firebase Authentication API
├── user_service.dart              # User data management API
├── course_service.dart            # Course CRUD operations
├── internship_service.dart        # Internship CRUD operations
├── application_service.dart       # Application submission API
├── feedback_service.dart          # Feedback management API
├── ticket_service.dart            # Support ticket API
├── admin_statistics_service.dart  # Analytics data API
├── progress_service.dart          # Progress tracking API
└── notification_service.dart      # Notification system API
```

---

## 🔐 Authentication API (How It Works)

### Firebase Authentication Service
**File**: `lib/services/auth_service.dart`

#### 1. User Sign Up API
```dart
Future<UserCredential> signUp(String email, String password, String name)
```

**Flow**:
1. App captures email, password, and name from signup form
2. Service calls Firebase Auth: `auth.createUserWithEmailAndPassword()`
3. Firebase creates auth user in Authentication database
4. User profile stored in Firestore under `users/{uid}`
5. Returns UserCredential with user UID
6. App navigates to onboarding screen

**Request**:
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "name": "John Doe"
}
```

**Response** (Success):
```json
{
  "uid": "abc123xyz",
  "email": "user@example.com",
  "displayName": "John Doe",
  "createdAt": "2026-01-22T10:30:00Z"
}
```

#### 2. User Login API
```dart
Future<UserCredential> login(String email, String password)
```

**Flow**:
1. User enters email and password on login screen
2. Service calls: `auth.signInWithEmailAndPassword()`
3. Firebase validates credentials against auth database
4. If valid, returns auth token stored in secure local storage
5. User's role (learner/admin) fetched from Firestore
6. Dashboard loads based on role

**Request**:
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response** (Success):
```json
{
  "uid": "abc123xyz",
  "email": "user@example.com",
  "tokenId": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEifQ...",
  "role": "learner"
}
```

#### 3. User Logout API
```dart
Future<void> logout()
```

**Flow**:
1. User taps "Logout" in profile settings
2. Service calls: `auth.signOut()`
3. Local auth token removed from secure storage
4. All active StreamBuilders unsubscribe
5. App navigates back to login screen
6. State reset

---

## 👤 User Service API

### File: `lib/services/user_service.dart`

#### 1. Fetch User Profile
```dart
Future<UserModel> getUserProfile(String uid)
```

**How It Works**:
1. App calls service with user UID
2. Service queries Firestore: `firestore.collection('users').doc(uid).get()`
3. Firestore database returns user document
4. Service parses JSON response into `UserModel` dart object
5. App displays profile on profile screen

**Firestore Collection Path**: `users/{uid}`

**Database Document Structure**:
```json
{
  "uid": "abc123xyz",
  "name": "John Doe",
  "email": "user@example.com",
  "phoneNumber": "+1234567890",
  "profileImageUrl": "https://storage.googleapis.com/...",
  "resumeUrl": "https://storage.googleapis.com/resumes/...",
  "bio": "Career enthusiast",
  "skills": ["Flutter", "Dart", "Firebase"],
  "role": "learner",
  "createdAt": "2026-01-22T10:30:00Z",
  "updatedAt": "2026-01-23T15:45:00Z",
  "enrolledCourses": ["course1", "course2"],
  "appliedInternships": ["internship1"]
}
```

#### 2. Update User Profile
```dart
Future<void> updateUserProfile(String uid, Map<String, dynamic> data)
```

**How It Works**:
1. User edits profile fields (name, phone, bio)
2. Service calls: `firestore.collection('users').doc(uid).update(data)`
3. Firestore updates document fields
4. Real-time listener notifies app of changes
5. Profile screen UI updates automatically

**Request**:
```json
{
  "phoneNumber": "+1987654321",
  "bio": "New bio text",
  "skills": ["Flutter", "Dart", "Firebase", "GraphQL"]
}
```

#### 3. Stream User Profile (Real-time)
```dart
Stream<UserModel> streamUserProfile(String uid)
```

**How It Works**:
1. Profile screen calls service at initialization
2. Service sets up Firestore listener: `firestore.collection('users').doc(uid).snapshots()`
3. Firebase sends initial user data
4. **Real-time updates**: Any change to user doc triggers automatic stream update
5. StreamBuilder rebuilds UI with fresh data
6. Listener persists until screen disposed

---

## 📚 Course Service API

### File: `lib/services/course_service.dart`

#### 1. Fetch All Courses
```dart
Future<List<CourseModel>> getAllCourses()
```

**How It Works**:
1. Courses screen loads on app start
2. Service queries: `firestore.collection('courses').get()`
3. Firebase returns all course documents
4. Service converts each document to `CourseModel`
5. Returns list of 10-20 courses
6. UI displays in ListView

**Firestore Collection Path**: `courses/{courseId}`

**Course Document Structure**:
```json
{
  "courseId": "course001",
  "title": "Flutter Basics",
  "description": "Learn Flutter fundamentals",
  "instructor": "Jane Smith",
  "duration": "4 weeks",
  "difficulty": "Beginner",
  "enrollmentCount": 245,
  "price": 49.99,
  "imageUrl": "https://storage.googleapis.com/...",
  "createdAt": "2026-01-01T08:00:00Z",
  "rating": 4.5,
  "reviews": 128
}
```

#### 2. Stream Courses (Real-time Updates)
```dart
Stream<List<CourseModel>> streamCourses()
```

**How It Works**:
1. Courses screen uses StreamBuilder
2. Service creates: `firestore.collection('courses').snapshots()`
3. Firebase sends initial courses list
4. **Real-time**: When admin adds/removes course, stream auto-updates
5. StreamBuilder rebuilds courses list
6. Users see new courses without app restart

#### 3. Enroll in Course
```dart
Future<void> enrollCourse(String uid, String courseId)
```

**How It Works**:
1. User clicks "Enroll Now" button
2. Service performs two operations:
   - Add course to user's `enrolledCourses`: `users/{uid} → enrolledCourses.add(courseId)`
   - Increment course enrollment counter: `courses/{courseId} → enrollmentCount++`
3. Both Firestore write operations complete
4. Enrollment confirmed on UI
5. Course appears in user's "My Courses"

**Request**:
```json
{
  "uid": "user123",
  "courseId": "course001"
}
```

#### 4. Get Enrolled Courses
```dart
Future<List<CourseModel>> getEnrolledCourses(String uid)
```

**How It Works**:
1. User profile screen loads
2. Service reads: `users/{uid}.enrolledCourses` array
3. For each courseId in array, fetch course details
4. Returns list of enrolled course objects
5. Display under "My Learning" section

---

## 🏢 Internship Service API

### File: `lib/services/internship_service.dart`

#### 1. Fetch All Internships
```dart
Future<List<InternshipModel>> getAllInternships()
```

**Firestore Path**: `internships/{internshipId}`

**Document Structure**:
```json
{
  "internshipId": "intern001",
  "title": "Mobile Developer Intern",
  "company": "TechCorp Inc",
  "location": "San Francisco, CA",
  "workType": "Remote",
  "duration": "3 months",
  "stipend": "$500/month",
  "description": "Build mobile apps with Flutter...",
  "requirements": ["Flutter", "Dart", "REST APIs"],
  "applicationCount": 15,
  "imageUrl": "https://storage.googleapis.com/...",
  "createdAt": "2026-01-15T09:00:00Z"
}
```

#### 2. Apply for Internship
```dart
Future<void> applyInternship(String uid, String internshipId, ApplicationModel app)
```

**How It Works**:
1. User fills application form (name, email, phone, skills)
2. User uploads resume via FilePicker
3. Service uploads file to Firebase Storage: `gsutil/resumes/{uid}_{timestamp}.pdf`
4. Gets downloadable URL: `https://storage.googleapis.com/...`
5. Creates application document in Firestore:
   ```
   internships/{internshipId}/applications/{uid}
   ```
6. Stores application with resume URL
7. Increments application counter
8. Returns success confirmation

**Request**:
```json
{
  "uid": "user123",
  "internshipId": "intern001",
  "fullName": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "skills": "Flutter, Dart, REST APIs",
  "resumeUrl": "https://storage.googleapis.com/resumes/user123_1674365400000.pdf"
}
```

**Firestore Application Document**:
```json
{
  "uid": "user123",
  "userName": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "skills": "Flutter, Dart, REST APIs",
  "resumeUrl": "https://storage.googleapis.com/resumes/...",
  "status": "pending",
  "appliedAt": "2026-01-23T14:30:00Z",
  "rating": null,
  "adminNotes": null
}
```

---

## 📝 Feedback Service API

### File: `lib/services/feedback_service.dart`

#### 1. Submit User Feedback
```dart
Future<void> submitFeedback(String uid, FeedbackModel feedback)
```

**How It Works**:
1. User opens feedback form
2. Fills: category (bug/feature/general), rating (1-5 stars), comments
3. Service creates new document in: `feedback/{feedbackId}`
4. Document linked to user: `feedback/{feedbackId}.userId = uid`
5. Timestamp auto-added: `createdAt`
6. Firestore returns success
7. User sees "Thank you" confirmation

**Firestore Path**: `feedback/{feedbackId}`

**Feedback Document**:
```json
{
  "feedbackId": "fb001",
  "userId": "user123",
  "category": "feature",
  "rating": 4,
  "comment": "Great app! Add dark mode feature",
  "status": "new",
  "createdAt": "2026-01-23T16:00:00Z",
  "adminResponse": null,
  "respondedAt": null
}
```

#### 2. Admin Fetch Feedback
```dart
Stream<List<FeedbackModel>> streamAllFeedback()
```

**How It Works**:
1. Admin opens feedback management screen
2. Service queries: `firestore.collection('feedback').snapshots()`
3. Firebase returns all feedback documents sorted by date
4. StreamBuilder displays as list with filters
5. Real-time: New feedback appears immediately for admin

---

## 🎯 Application Service API

### File: `lib/services/application_service.dart`

#### 1. Fetch User Applications
```dart
Future<List<ApplicationModel>> getUserApplications(String uid)
```

**How It Works**:
1. Profile screen loads user's applications
2. Service queries: `firestore.collectionGroup('applications').where('uid', '==', uid).get()`
3. Searches across ALL internships for this user's applications
4. Returns list of applications with internship details
5. UI shows application status (pending/accepted/rejected)

#### 2. Update Application Status (Admin)
```dart
Future<void> updateApplicationStatus(String internshipId, String uid, String status, String notes)
```

**How It Works**:
1. Admin reviews application on admin dashboard
2. Admin selects status: "pending" → "accepted" or "rejected"
3. Admin adds notes if needed
4. Service updates: `internships/{internshipId}/applications/{uid}`
5. Firestore updates status and adminNotes fields
6. Real-time listener triggers:
   - User sees updated status on profile
   - Admin sees status change reflected immediately

---

## 🛟 Support Ticket API

### File: `lib/services/ticket_service.dart`

#### 1. Create Support Ticket
```dart
Future<void> createTicket(String uid, TicketModel ticket)
```

**Firestore Path**: `support_tickets/{ticketId}`

**Document Structure**:
```json
{
  "ticketId": "ticket001",
  "userId": "user123",
  "subject": "Cannot upload resume",
  "description": "File upload fails with error",
  "category": "technical",
  "priority": "high",
  "status": "open",
  "createdAt": "2026-01-23T17:00:00Z",
  "resolvedAt": null,
  "replies": []
}
```

#### 2. Stream Tickets (Real-time)
```dart
Stream<List<TicketModel>> streamUserTickets(String uid)
```

**How It Works**:
1. User opens support tickets screen
2. Service listener: `tickets.where('userId', '==', uid).snapshots()`
3. Real-time updates as admin responds
4. User sees new replies instantly

---

## 💾 Firebase Storage API

### File: `lib/services/application_service.dart`

#### Resume Upload Flow
```
Step 1: User picks file (FilePicker)
        ↓
Step 2: Service uploads to: gs://bucket/resumes/{uid}_{timestamp}.pdf
        ↓
Step 3: Firebase returns download URL
        ↓
Step 4: URL stored in Firestore (application document)
        ↓
Step 5: Admin can access resume via URL
```

**Upload Code Pattern**:
```dart
Future<String> uploadResume(File file, String uid) async {
  String fileName = '${uid}_${DateTime.now().millisecondsSinceEpoch}.pdf';
  Reference ref = FirebaseStorage.instance.ref().child('resumes/$fileName');
  
  await ref.putFile(file);
  String downloadUrl = await ref.getDownloadURL();
  
  return downloadUrl;
}
```

---

## 📊 Admin Statistics API

### File: `lib/services/admin_statistics_service.dart`

#### Fetch Dashboard Statistics
```dart
Future<AdminStatisticsModel> getStatistics()
```

**How It Works**:
1. Admin dashboard loads
2. Service performs aggregation queries:
   - Count total users: `firestore.collection('users').count()`
   - Count courses: `firestore.collection('courses').count()`
   - Count internships: `firestore.collection('internships').count()`
   - Count applications: `firestore.collectionGroup('applications').count()`
   - Get enrollment trends: `courses.snapshots()` with data aggregation
3. Returns all statistics
4. Charts render with data

**Response**:
```json
{
  "totalUsers": 1250,
  "totalCourses": 45,
  "totalInternships": 28,
  "totalApplications": 3420,
  "enrollmentTrend": [
    {"date": "2026-01-15", "count": 120},
    {"date": "2026-01-16", "count": 135},
    {"date": "2026-01-17", "count": 142}
  ],
  "applicationStatusBreakdown": {
    "pending": 420,
    "accepted": 280,
    "rejected": 150
  }
}
```

---

## 🔄 Real-time Data Synchronization (How It Works)

### StreamBuilder Pattern
```dart
StreamBuilder<List<CourseModel>>(
  stream: courseService.streamCourses(),  // ← Service creates Firestore listener
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (snapshot.hasData) {
      return ListView(
        children: snapshot.data!.map((course) => CourseCard(course)).toList(),
      );
    }
    
    return Center(child: Text('No courses found'));
  },
)
```

**What Happens**:
1. StreamBuilder initializes → calls `streamCourses()`
2. Service creates Firestore listener: `courses.snapshots()`
3. Firebase sends initial data → connectionState = `active`
4. Builder runs → displays courses list
5. **Real-time**: Admin adds course → Firestore triggers snapshot
6. Service receives updated data → emits new event
7. StreamBuilder automatically rebuilds with new data
8. Users see new course instantly (no refresh needed)

---

## ⚠️ Error Handling & Retry Logic

### Service Error Handling Pattern
```dart
Future<void> enrollCourse(String uid, String courseId) async {
  try {
    await firestore.collection('users').doc(uid).update({
      'enrolledCourses': FieldValue.arrayUnion([courseId])
    });
    
    debugPrint('✓ Enrollment successful');
  } on FirebaseException catch (e) {
    if (e.code == 'permission-denied') {
      throw Exception('Permission denied: Check Firestore rules');
    } else if (e.code == 'not-found') {
      throw Exception('User or course not found');
    } else {
      throw Exception('Enrollment failed: ${e.message}');
    }
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
}
```

**Common Errors & Handling**:
- `permission-denied`: Firestore security rules issue
- `network-error`: Connection lost, retry after 2 seconds
- `not-found`: Invalid UID or collection path
- `unauthenticated`: User token expired, prompt login

---

## 🔐 Security & Authentication Tokens

### How Authentication Works
1. User logs in → Firebase Auth generates ID token
2. Token stored securely on device
3. **Every API request** includes token in header:
   ```
   Authorization: Bearer {idToken}
   ```
4. Firebase validates token before allowing access
5. Token expires after 1 hour
6. App auto-refreshes token silently
7. If refresh fails → user logged out, prompt re-login

### Firestore Security Rules
```javascript
// Only authenticated users can access
match /users/{uid} {
  allow read: if request.auth.uid == uid;
  allow write: if request.auth.uid == uid;
}

// Anyone authenticated can read courses
match /courses/{courseId} {
  allow read: if request.auth != null;
  allow write: if request.auth.token.admin == true;
}
```

---

## 📐 Data Request/Response Cycle Example

### Complete User Enrollment Flow
```
┌──────────────────┐
│ User UI           │ User clicks "Enroll Now"
└────────┬──────────┘
         │
         ▼
┌──────────────────────────────────┐
│ enrollCourse(uid, courseId)      │ App calls service method
│ in courses_screen.dart           │
└────────┬─────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────┐
│ courseService.enrollCourse(uid, courseId)  │ Service processes
└────────┬─────────────────────────────────────┘
         │
    ┌────▼──────────────────────────────────────┐
    │ Firestore Write Operations:                │
    │ 1. users/{uid} add courseId to array      │
    │ 2. courses/{courseId} increment counter   │
    └────┬──────────────────────────────────────┘
         │
         ▼
┌────────────────────────────┐
│ Firebase Cloud Firestore   │ Database updated
│ • User document modified   │
│ • Course enrollment +1     │
└────────┬───────────────────┘
         │
         ▼
┌────────────────────────────────────────────┐
│ Real-time Listeners Triggered:             │
│ • streamEnrolledCourses() emits new data   │
│ • streamCourses() emits updated count      │
└────────┬───────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ StreamBuilder Auto-Rebuilds:     │
│ • Profile shows new enrollment   │
│ • Courses list shows updated +1  │
│ • UI refreshes instantly         │
└──────────────────────────────────┘
```

---

## 📝 Database Collection Structure

### Full Database Map
```
firebase_project/
├── users/
│   └── {uid}/
│       ├── name
│       ├── email
│       ├── phoneNumber
│       ├── profileImageUrl
│       ├── resumeUrl
│       ├── enrolledCourses: [courseId1, courseId2, ...]
│       ├── appliedInternships: [internshipId1, ...]
│       └── role: "learner" | "admin"
│
├── courses/
│   └── {courseId}/
│       ├── title
│       ├── description
│       ├── instructor
│       ├── duration
│       ├── difficulty
│       ├── enrollmentCount
│       └── price
│
├── internships/
│   └── {internshipId}/
│       ├── title
│       ├── company
│       ├── location
│       ├── workType
│       ├── duration
│       ├── stipend
│       ├── applicationCount
│       └── applications/
│           └── {userId}/
│               ├── fullName
│               ├── email
│               ├── phone
│               ├── resumeUrl
│               ├── status: "pending" | "accepted" | "rejected"
│               └── appliedAt
│
├── feedback/
│   └── {feedbackId}/
│       ├── userId
│       ├── category
│       ├── rating
│       ├── comment
│       ├── status
│       └── createdAt
│
└── support_tickets/
    └── {ticketId}/
        ├── userId
        ├── subject
        ├── description
        ├── status
        ├── priority
        └── createdAt
```

---

## 🚀 API Testing Checklist

- [ ] User registration creates auth user + Firestore profile
- [ ] Login returns valid auth token
- [ ] Profile updates reflect in real-time
- [ ] Course enrollment increments counter
- [ ] Resume upload creates Storage URL
- [ ] Feedback appears on admin dashboard instantly
- [ ] Applications persist with resume URL
- [ ] Admin status changes notify user immediately
- [ ] Logout clears local token
- [ ] Network reconnect syncs pending changes

---

## 📈 Week 2 Summary

| Component | Implementation | Status |
|-----------|---|---|
| Authentication API | Firebase Auth + Firestore | ✅ Complete |
| User Service | CRUD + Real-time streams | ✅ Complete |
| Course Service | Enrollment + Analytics | ✅ Complete |
| Internship Service | Applications + Resume | ✅ Complete |
| Feedback API | Submission + Admin Review | ✅ Complete |
| Storage API | Resume upload/download | ✅ Complete |
| Admin Statistics | Aggregation queries | ✅ Complete |
| Real-time Sync | Firestore listeners | ✅ Complete |
| Error Handling | Exception management | ✅ Complete |
| Security | Auth tokens + Rules | ✅ Complete |

---

## 🔗 Next Steps (Week 3 Roadmap)

- Push notifications for applications
- Offline data caching
- Performance optimization
- Analytics integration
- Advanced filtering and search
- Payment processing integration

---

**Week 2 Completion**: January 26, 2026
**Flutter Version**: 3.38.7
**Dart Version**: 3.10.7
**API Architecture**: Firebase REST + Firestore Real-time
