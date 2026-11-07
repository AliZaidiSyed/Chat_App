# Flutter Chat App

This is a real-time messaging application built with **Flutter** and **Dart**. It is designed to help users connect, discover other users, chat privately, share media, create group conversations, and communicate through voice and video calls.

## Features

- **Google sign-in:** Authenticate users with Firebase Authentication and Google Sign-In.
- **User discovery:** Find registered users and start conversations.
- **One-to-one messaging:** Send and receive chat messages with Cloud Firestore.
- **Media sharing:** Select images from the device and share supported chat media.
- **Group conversations:** Create groups and manage group members and group information.
- **Group administration:** Support group admins and member-management actions.
- **Typing indicators:** Show when another participant is typing.
- **Voice and video calls:** Integrate calling UI and signaling with ZEGOCLOUD.
- **Push notifications:** Receive remote notifications through Firebase Cloud Messaging.
- **Local notifications:** Display notifications locally with Flutter Local Notifications.
- **State management:** Organize reactive application state with Riverpod.
- **Cloud media storage:** Integrate Supabase Storage; the supplied dependencies also include Firebase Storage.

## Tech Stack

| Technology / Package | How it is used in Connecto | Why it is used |
|---|---|---|
| **Flutter** | Builds the app's cross-platform user interface. | Provides a shared UI codebase for supported platforms. |
| **Dart** | Main programming language for screens, models, providers, and services. | Works with Flutter and supports asynchronous application logic. |
| **flutter_riverpod** | Manages and exposes application state through providers and notifiers. | Helps separate UI from state and application logic. |
| **firebase_core** | Initializes Firebase before Firebase services are used. | Provides the base connection to Firebase products. |
| **firebase_auth** | Handles user authentication. | Provides Firebase-managed sign-in and user-session management. |
| **google_sign_in** | Allows users to choose and authenticate with a Google account. | Provides the Google account sign-in flow. |
| **cloud_firestore** | Stores and syncs application data such as users, chats, messages, and group information. | Supports cloud-hosted data and real-time listeners for chat updates. |
| **firebase_messaging** | Receives Firebase Cloud Messaging (FCM) push messages. | Helps notify users about relevant events when the app is in the background or not open. |
| **flutter_local_notifications** | Displays notifications on the device. | Provides local notification presentation and notification-channel support. |
| **supabase_flutter** | Connects the Flutter app to Supabase services, including Storage where configured. | Provides a Flutter client for Supabase-backed media and other configured services. |
| **firebase_storage** | Firebase Storage client dependency is included in `pubspec.yaml`. | Can upload and retrieve files from Firebase Storage if the app's code uses it. Check the code before assuming it is still part of the active upload flow. |
| **zego_uikit_prebuilt_call** | Supplies the prebuilt calling interface used for voice/video calling integration. | Reduces the amount of custom call UI and call-flow code required. |
| **zego_uikit** | Provides core ZEGOCLOUD UI and calling components. | Supports the ZEGOCLOUD calling experience. |
| **zego_uikit_signaling_plugin** | Provides signaling integration for call invitations and call events. | Allows calling participants to coordinate call sessions. |
| **image_picker** | Lets users select images from the device. | Provides access to gallery/camera selection flows supported by the platform. |
| **permission_handler** | Requests and checks runtime permissions. | Helps request permissions needed by features such as camera, microphone, or media access. |
| **intl** | Formats dates, times, and other locale-sensitive values. | Makes timestamps and date display easier to format consistently. |
| **uuid** | Generates unique identifiers where used by the app. | Helps create unique IDs for records or uploaded files. |
| **cherry_toast** | Displays toast-style feedback messages. | Provides user feedback for successful actions and errors. |

## Project Structure

```text
chat_app/
├── android/                         # Android platform project and configuration
├── assets/
│   └── images/
│       ├── logo.png                 # App logo image
│       └── search.png               # Search illustration/image
├── lib/
│   ├── core/
│   │   ├── secrets/                 # App/service configuration (keep private keys out of Git)
│   │   └── utils/                   # Shared helper functions and utilities
│   ├── chat/
│   │   ├── model/                   # User and chat data models
│   │   ├── service/                 # Chat and database operations
│   │   └── screens/                 # Chat-related screens and widgets
│   └── group_chats/
│       ├── model/                   # Group and group-message models
│       └── provider/                # Group chat state management
├── supabase/                        # Supabase-related files, if maintained in this repo
├── pubspec.yaml                     # Flutter dependencies and asset declarations
├── pubspec.lock                     # Resolved dependency versions
└── README.md                        # Project documentation
```

## Repository

Find the source code and project updates on GitHub:

**[AliZaidiSyed/Chat_App](https://github.com/AliZaidiSyed/Chat_App)**
