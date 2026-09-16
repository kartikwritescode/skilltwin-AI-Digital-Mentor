# SkillTwin: Free Firebase Cloud Messaging (FCM) & Native Notifications Guide

This guide explains SkillTwin's dual notification architecture and provides step-by-step instructions to configure **Firebase Cloud Messaging (FCM) for 100% free** under Google's Spark plan.

---

## 1. SkillTwin Notification Architecture

SkillTwin employs a robust dual-layer notification system:

| Layer | Technology | Cost | Server Needed? | Internet Needed? | Status in SkillTwin |
|---|---|---|---|---|---|
| **Layer 1: Offline Native Alarms** | `flutter_local_notifications` | **Free Forever** | **No** (runs on Android OS) | **No** (works 100% offline) | **Pre-configured & Active** |
| **Layer 2: Remote Push Messages** | Firebase Cloud Messaging (FCM) | **Free Forever** (Spark Tier) | Optional (Console or server) | Yes | **Ready to Connect** |

### Why Layer 1 is Already Active
Out-of-the-box, SkillTwin schedules local Android native alarms directly on the user's phone:
- **10:00 AM Morning Mission**: Reminds the user of today's target topic and key concepts.
- **9:00 PM Evening Trolling Roast**: A witty, sarcastic notification that fires if today's study hasn't been completed yet.
- **Instant Test Trigger**: Tap the 🔔 icon in the Home Screen AppBar to test the trolling notification right now!

---

## 2. Setting Up Firebase Cloud Messaging (100% Free)

Firebase Cloud Messaging (FCM) is completely free on the Google Firebase **Spark Plan** (unlimited push notifications with zero billing required).

### Step 1: Create a Free Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **"Add project"** (or select an existing Google Cloud project).
3. Name your project (e.g., `skilltwin-app`).
4. You can disable Google Analytics or leave it on (it's free either way).
5. Click **"Create project"**.

---

### Step 2: Register Android App in Firebase
1. In your Firebase Project Overview dashboard, click the **Android icon** (`</>`) to add an Android app.
2. Enter the **Android package name**:
   ```
   com.example.skilltwin
   ```
   *(This must match the `applicationId` and `namespace` in `android/app/build.gradle.kts`)*.
3. App nickname (optional): `SkillTwin`.
4. Debug signing certificate SHA-1: Optional for push notifications (can leave blank for now).
5. Click **"Register app"**.

---

### Step 3: Download and Place `google-services.json`
1. Click **"Download google-services.json"**.
2. Move the downloaded `google-services.json` file into your Flutter project's Android app folder:
   ```
   skilltwin/android/app/google-services.json
   ```

---

### Step 4: Configure Gradle for Google Services

#### A. In `android/build.gradle.kts`:
Add the Google Services classpath inside `buildscript { dependencies { ... } }`:
```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}
```

#### B. In `android/app/build.gradle.kts`:
Apply the Google Services plugin:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // <-- Add this line
}
```

---

### Step 5: Add Flutter Firebase Dependencies
In `pubspec.yaml`, add under `dependencies`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.10.1
  firebase_messaging: ^15.2.1
```
Then run:
```bash
flutter pub get
```

---

### Step 6: Initialize Firebase in Flutter (`lib/main.dart`)
Update `main()` in `lib/main.dart` to initialize Firebase:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (after google-services.json is added)
  await Firebase.initializeApp();
  
  // Request notification permissions
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  // Get Device FCM Token
  String? token = await messaging.getToken();
  debugPrint('FCM Registration Token: $token');
  
  // Handle background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService.instance.initialize();
  runApp(...);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("FCM Background Message: ${message.messageId}");
}
```

---

### Step 7: Send Free Test Push from Firebase Console (No Server Needed!)
1. In the Firebase Console left menu, navigate to **Engage** > **Messaging** (or **Cloud Messaging**).
2. Click **"Create your first campaign"** > choose **"Firebase Notification messages"**.
3. Fill in:
   - **Notification title**: e.g., `🚨 Breaking News: You're slacking again`
   - **Notification text**: `Time spent on System Design: 0 mins. Open SkillTwin and fix your life!`
4. Click **"Send test message"**, paste your device's FCM token from the console logs, and click **"Test"**.
5. The push notification will immediately pop up on your Android device!

---

## 3. How to Edit & Customize Trolling Messages

All trolling, roasting, and encouragement messages are stored in a single file:
📂 [lib/core/notifications/notification_messages.dart](file:///c:/Users/Kartik/StudioProjects/skilltwin/lib/core/notifications/notification_messages.dart)

### Supported Categories:
1. `morningTaskReminders`: Motivational morning wake-up calls.
2. `endOfDayTrolling`: 9:00 PM sarcastic roasts for learners who haven't studied.
3. `backlogRoasts`: Roasts about letting backlogged topics pile up like laundry.
4. `streakSavers`: Emergency warnings before midnight streak reset.
5. `milestoneCelebration`: Humorous high-fives when topics are mastered.

### Supported Dynamic Placeholders:
- `{topic}`: Title of today's target topic.
- `{backlog}`: Number of backlogged topics behind schedule.
- `{mins}`: Daily study commitment in minutes (e.g. 30).
- `{streak}`: Current streak in days.

### Example:
```dart
NotificationTemplate(
  title: "👀 Even your Wi-Fi is disappointed in you",
  body: "You've been on your phone for hours, yet '{topic}' sits untouched.",
)
```
Add any new jokes, roasts, or memes directly to that file and they will automatically rotate into your notifications!
