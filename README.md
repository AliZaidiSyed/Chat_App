# Flutter Chat App

A real-time messaging application built with **Flutter** and **Dart**, designed to help users discover other users, communicate through private and group conversations, share media, and make one-to-one / group voice and video calls.

## Features

- **Google sign-in:** Authenticate users with Firebase Authentication and Google Sign-In.
- **User discovery:** Find registered users and start conversations.
- **One-to-one messaging:** Send and receive private messages in real time with Cloud Firestore.
- **Media sharing:** Select images from the device and share supported chat media.
- **Group conversations:** Create group chats, add or remove members, and update group information.
- **Group administration:** Support group admins and member-management actions.
- **Typing indicators:** Show when another participant is typing.
- **One-to-one and group calling:** Make individual or group voice and video calls using ZEGOCLOUD.
- **Push notifications:** Receive remote notifications through Firebase Cloud Messaging (FCM).
- **Local notifications:** Display notifications on the device with Flutter Local Notifications.
- **State management:** Manage application state with Riverpod.
- **Cloud media storage:** Integrate Supabase Storage for supported profile and chat media. The project dependencies also include Firebase Storage.

## Tech Stack

| Technology / Package | How it is used in the app | Why it is used |
|---|---|---|
| **Flutter** | Builds the application's user interface. | Provides a shared codebase for supported platforms. |
| **Dart** | Powers the app's screens, models, providers, and services. | Works with Flutter and supports asynchronous application logic. |
| **flutter_riverpod** | Manages and exposes application state through providers and notifiers. | Helps separate UI code from state and application logic. |
| **firebase_core** | Initializes Firebase before its services are used. | Provides the base connection to Firebase products. |
| **firebase_auth** | Handles user authentication and sessions. | Provides managed authentication for the application. |
| **google_sign_in** | Provides the Google account sign-in flow. | Lets users authenticate using their Google accounts. |
| **cloud_firestore** | Stores and synchronizes user, chat, message, and group data. | Provides cloud-hosted data with real-time listeners for chat updates. |
| **firebase_messaging** | Receives Firebase Cloud Messaging (FCM) messages. | Enables remote push notifications. |
| **flutter_local_notifications** | Displays notifications locally on the device. | Provides local notification presentation and notification-channel support. |
| **supabase_flutter** | Connects the app to Supabase services, including Storage where configured. | Provides a Flutter client for Supabase-backed media and other configured services. |

| **zego_uikit_prebuilt_call** | Provides the prebuilt calling interface for one-to-one and group voice/video calls. | Reduces the amount of custom calling UI and call-flow code required. |
| **zego_uikit** | Provides core ZEGOCLOUD UI and calling components. | Supports the app's ZEGOCLOUD calling experience. |
| **zego_uikit_signaling_plugin** | Handles call signaling, invitations, and call events. | Allows participants to coordinate call sessions. |
| **image_picker** | Lets users select images from the device. | Provides access to supported gallery and camera selection flows. |
| **permission_handler** | Checks and requests runtime permissions. | Helps request permissions required by features such as camera and microphone access. |
| **intl** | Formats dates, times, and locale-sensitive values. | Helps display timestamps and dates consistently. |
| **uuid** | Generates unique identifiers where used by the app. | Helps create unique IDs for records or uploaded files. |
| **cherry_toast** | Displays toast-style feedback messages. | Provides feedback for successful actions and errors. |

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
│   │   ├── secrets/                 # App/service configuration; keep private keys out of Git
│   │   └── utils/                   # Shared helper functions and utilities
│   ├── chat/
│   │   ├── model/                   # User and chat data models
│   │   ├── service/                 # Chat and database operations
│   │   └── screens/                 # Chat-related screens and widgets
│   └── group_chats/
│       ├── model/                   # Group and group-message models
│       └── provider/                # Group chat state management
├── supabase/                        # Supabase-related files, if included in the repository
├── pubspec.yaml                     # Flutter dependencies and asset declarations
├── pubspec.lock                     # Resolved dependency versions
└── README.md                        # Project documentation
```







## Repository

Find the source code and project updates on GitHub:

**[AliZaidiSyed/Chat_App](https://github.com/AliZaidiSyed/Chat_App)**
