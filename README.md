#  Flutter Chat App

it is a real-time messaging application built with **Flutter** and **Dart**. It allows users to discover other registered users, exchange private and group messages, share media, and communicate through one-to-one and group voice/video calls.

## Features

- **Google Sign-In:** Authenticate users with Firebase Authentication and Google Sign-In.
- **User Discovery:** Find registered users and start conversations.
- **One-to-One Messaging:** Send and receive private messages in real time using Cloud Firestore.
- **Media Sharing:** Select and share images and supported chat media.
- **Group Conversations:** Create group chats, manage members, and update group information.
- **Group Administration:** Support group administrators and member-management actions.
- **Typing Indicators:** Show when another participant is typing.
- **One-to-One and Group Calling:** Make individual or group voice and video calls using ZEGOCLOUD.
- **Push Notifications:** Receive remote notifications through Firebase Cloud Messaging (FCM).
- **Local Notifications:** Display notifications on the device using Flutter Local Notifications.
- **State Management:** Manage application state with Riverpod.
- **Cloud Media Storage:** Use Supabase Storage for supported profile and chat media.

## Tech Stack

| Technology / Package | How it is used in Connecto | Why it is used |
|---|---|---|
| **Flutter** | Builds the application's user interface. | Provides a shared codebase for supported platforms. |
| **Dart** | Powers the app's screens, models, providers, and services. | Works with Flutter and supports asynchronous application logic. |
| **flutter_riverpod** | Manages and exposes application state through providers and notifiers. | Helps separate UI code from state and application logic. |
| **firebase_core** | Initializes Firebase before its services are used. | Provides the base connection to Firebase products. |
| **firebase_auth** | Handles user authentication and session management. | Provides managed authentication for the application. |
| **google_sign_in** | Provides the Google account sign-in flow. | Allows users to authenticate with their Google accounts. |
| **cloud_firestore** | Stores and synchronizes user, chat, message, and group data. | Provides cloud-hosted data and real-time listeners for chat updates. |
| **firebase_messaging** | Receives Firebase Cloud Messaging messages. | Enables remote push notifications. |
| **flutter_local_notifications** | Displays notifications locally on the device. | Provides local notification presentation and notification-channel support. |
| **supabase_flutter** | Connects the app to Supabase services, including Storage. | Provides the Flutter client used to access configured Supabase services and media storage. |
| **zego_uikit_prebuilt_call** | Provides the prebuilt calling interface for one-to-one and group calls. | Reduces the amount of custom calling UI and call-flow code required. |
| **zego_uikit** | Provides core ZEGOCLOUD UI and calling components. | Supports the app's ZEGOCLOUD calling experience. |
| **zego_uikit_signaling_plugin** | Supports call signaling, invitations, and call events. | Allows participants to coordinate call sessions. |
| **image_picker** | Lets users select images from the device. | Provides access to supported gallery and camera selection flows. |
| **permission_handler** | Checks and requests runtime permissions. | Helps request permissions required by features such as camera and microphone access. |
| **intl** | Formats dates, times, and locale-sensitive values. | Helps display timestamps and dates consistently. |
| **uuid** | Generates unique identifiers where used by the app. | Helps create unique IDs for records and files. |
| **cherry_toast** | Displays toast-style feedback messages. | Provides feedback for successful actions and errors. |
| **cupertino_icons** | Provides Cupertino-style icons. | Supplies iOS-style icons for Flutter interfaces. |



## Project Structure

The following shows the top-level structure currently present in the GitHub repository. The `lib/` folder contains the Flutter application source code; open that folder in the repository to view its current feature folders and Dart files.

```text
Chat_App/
├── .vscode/                    # Editor configuration
├── android/                    # Android platform project and configuration
├── assets/
│   └── images/
│       ├── logo.png            # App logo
│       └── search.png          # Search image/illustration
├── ios/                        # iOS platform project
├── lib/                        # Flutter application source code
├── linux/                      # Linux platform project
├── macos/                      # macOS platform project
├── node_modules/               # Installed Node.js dependencies for Supabase CLI tooling
├── supabase/                   # Supabase project files
├── test/                       # Flutter tests
├── web/                        # Web platform project
├── windows/                    # Windows platform project
├── .gitattributes              # Git attributes and LFS tracking rules
├── .gitignore                  # Files excluded from Git
├── .metadata                   # Flutter project metadata
├── analysis_options.yaml       # Dart analyzer and lint configuration
├── firebase.json               # Firebase project/tool configuration
├── package-lock.json           # Locked Node.js dependency versions
├── package.json                # Node.js project dependencies (Supabase CLI)
├── pubspec.lock                # Locked Flutter/Dart dependency versions
├── pubspec.yaml                # Flutter dependencies, SDK constraint, and assets
└── README.md                   # Project documentation
```



### 6. Run the App

Connect an Android device or start an emulator, then run:

```bash
flutter devices
flutter run
```



## Repository

Find the source code and project updates on GitHub:

**[AliZaidiSyed/Chat_App](https://github.com/AliZaidiSyed/Chat_App)**
