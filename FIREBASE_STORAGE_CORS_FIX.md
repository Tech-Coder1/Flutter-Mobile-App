# Firebase Storage CORS Fix

## Problem
File uploads to Firebase Storage are blocked by CORS policy when running from localhost.

## Solution
Configure CORS for your Firebase Storage bucket to allow localhost origins.

### Step 1: Install Google Cloud SDK (if not installed)

```bash
# macOS (using Homebrew)
brew install google-cloud-sdk

# Or download from: https://cloud.google.com/sdk/docs/install
```

### Step 2: Authenticate with Google Cloud

```bash
gcloud auth login
```

### Step 3: Set your Firebase project

```bash
gcloud config set project excelerate-app-4b169
```

### Step 4: Apply CORS configuration

The `cors.json` file has been created in the project root. Apply it:

```bash
gsutil cors set cors.json gs://excelerate-app-4b169.firebasestorage.app
```

### Step 5: Verify CORS configuration

```bash
gsutil cors get gs://excelerate-app-4b169.firebasestorage.app
```

## Alternative: Update Firebase Storage Rules (Temporary Dev Fix)

If you can't install gsutil, you can update Firebase Storage rules in the Firebase Console:

1. Go to: https://console.firebase.google.com/project/excelerate-app-4b169/storage/rules
2. Update the rules to:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /resumes/{userId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## CORS Configuration Details

The `cors.json` file allows:
- Origins: `http://localhost:*` and `http://127.0.0.1:*`
- Methods: GET, POST, PUT, DELETE, HEAD
- Max Age: 3600 seconds (1 hour)
- Response headers for file upload operations

## Testing

After applying CORS:
1. Restart your Flutter app: `flutter run -d chrome`
2. Try uploading a resume file through the application form
3. The CORS error should be resolved

## Production Note

For production deployment:
- Add your production domain to the CORS configuration
- Update origins to include `https://yourdomain.com`
- Keep security rules strict (authenticated users only)
