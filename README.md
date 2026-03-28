# 🚀 SkillSync

**Real-Time Skill Sharing & Live Broadcasting App**

SkillSync is a high-performance, Flutter-based cross-platform application that enables users to broadcast live video/audio sessions and learn from others in real-time. By integrating **Agora RTC** for seamless streaming and **Firebase** for scalable backend services, SkillSync provides a robust environment for digital knowledge sharing.

---

## 📌 Overview

SkillSync is designed as a one-to-many live broadcasting platform where users can:
* **Share Skills:** Broadcast live video/audio to a global audience.
* **Discover:** Browse and join ongoing sessions in real-time.
* **Interact:** Engage with broadcasters through an integrated real-time chat.

The system ensures **low-latency streaming**, secure token-based access, and dynamic real-time engagement.

---

## 🛠 Tech Stack

### 📱 Frontend
* **Framework:** Flutter (Dart)
* **State Management:** Provider

### 🔥 Backend (Firebase)
* **Authentication:** Secure Email/Password login.
* **Cloud Firestore:** Real-time NoSQL database for stream metadata and chat.
* **Firebase Storage:** Scalable media storage for stream thumbnails.

### 📡 Real-Time Communication
* **Agora RTC Engine:** (`agora_rtc_engine`) for high-quality video/audio streaming.
* **Token Server:** Go-based backend for secure, time-limited authentication.

### 🔐 Other Integrations
* `permission_handler`: Seamless camera and microphone access.
* `http`: REST API communication for token fetching.

---

## ✨ Key Features

* **🎥 Live Streaming:** One-to-many broadcasting using Agora’s `LiveBroadcasting` profile for optimized quality.
* **👥 Dynamic User Roles:** Clear distinction between **Broadcasters** (hosts) and **Audience** (viewers).
* **🔐 Secure Access:** Time-limited Agora tokens fetched from an external Go server to prevent unauthorized access.
* **💬 Real-Time Chat:** Interaction powered by Firestore `snapshots()` for instant messaging during sessions.
* **👀 Live Viewer Count:** Real-time tracking using Firestore atomic increments.
* **📂 Lifecycle Management:** Automated creation/deletion of stream listings in Firestore.
* **🖼 Thumbnail Upload:** Custom stream previews managed via Firebase Storage.
* **🔎 Stream Discovery:** A real-time dashboard to browse all active live sessions.

---

## 🏗 Project Structure

```text
lib/
│── pages/
│   └── broadcast_screen.dart    # Core Agora streaming & UI logic
│
│── resources/
│   └── firestore_methods.dart   # Firebase CRUD & stream lifecycle operations
│
│── providers/
│   └── user_provider.dart       # Global user state management
│
│── config/
│   └── appid.dart               # Agora configuration & App ID
```
---

## 🔄 Application Workflow
* **Authentication:** User signs in via Firebase; profile data is synced to Firestore.

* **Discovery:** The Home Screen fetches active stream documents from Firestore.

* **Start Streaming:** User sets a title and uploads a thumbnail to Firebase Storage.

** **App fetches a secure token from the Go server.

** **The user joins the Agora channel as a Broadcaster.

* **Interaction:** Audience members join as Viewers, triggering viewer count updates and enabling real-time chat via Firestore streams.

* **End Stream:** When the host stops, the app leaves the Agora channel and deletes the Firestore document to remove the listing.

---

## 🚀 Getting Started
Follow these steps to set up the project and get it running on your local machine.

✅ Prerequisites
Before you begin, ensure you have the following installed and configured:

Flutter SDK: Run flutter doctor to confirm your environment is ready.

Firebase Project: A registered project on the Firebase Console.

Agora Developer Account: An active account with a project created in the Agora Console.

⚙️ Setup Instructions
1. Firebase Setup
Create a Project: Start a new project in the Firebase Console.

Enable Services: Navigate to the dashboard and enable Authentication (Email/Password), Firestore Database, and Storage.

Add Configuration Files:

Android: Place google-services.json in android/app/.

iOS: Place GoogleService-Info.plist in ios/Runner/.

2. Agora Setup
Generate App ID: Create a project in the Agora Console and copy your App ID.

Update Config: Open lib/config/appid.dart and replace the placeholder value with your actual ID.

3. Token Server
This app requires a Go-based token server to generate RTC tokens for secure communication.

Ensure the server is active and reachable.

Verify that your API endpoint is correctly configured in your Flutter HTTP request logic.

---

## 🛠️ Installation & Run
Run the following commands in your terminal to get the app started:

Bash
# Fetch the required flutter packages
flutter pub get

# Launch the app on your connected device or emulator
flutter run
