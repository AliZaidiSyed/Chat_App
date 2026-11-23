<div align="center">

# Connecto - Flutter Chat App
### A Real-Time Messaging and Calling Application Built with Flutter

![Firebase](https://img.shields.io/badge/Firebase-Authentication_%26_Firestore-orange?logo=firebase)
![Supabase](https://img.shields.io/badge/Supabase-Storage_%26_Edge_Functions-3ECF8E?logo=supabase&logoColor=white)

</div>

Connecto is a Flutter chat application for discovering users, communicating through private and group conversations, sharing images, and making audio/video calls. It uses Firebase for authentication and real-time data, Supabase for media storage, Riverpod for state management, and ZEGOCLOUD for calls.

---

## 📱 Screenshots

The following screenshots show the main Connecto features, from authentication and chat screens to group management and calling.

<div align="center">
![Uploading Connecto_GitHub_All_Features.png…]()


</div>



---




## 🌟 Features

### 🔐 Authentication

- Register and sign in with email and password using Firebase Authentication.
- Sign in with a Google account.
- Restore the authenticated session when the app is reopened.
- Save user details in Cloud Firestore.
- Log out from the profile screen.

### 👥 User Discovery & Requests

- Browse registered users.
- Search for users by name or email.
- Send, accept, and reject message/friend requests.
- Start one-to-one conversations after connecting with another user.
- Remove an existing friendship.

### 💬 One-to-One Messaging

- Send and receive text messages in real time.
- Share images in private conversations.
- Open shared images in a full-screen view.
- Show live typing indicators.
- Display message timestamps, read status, and unread message counts.
- Show the latest message in the chat list.
- Display users' online status and last-seen information.

### 👨‍👩‍👧‍👦 Group Chats

- Create groups and select members.
- Send group text messages and images.
- View group members and member counts.
- Display group typing indicators and unread message counts.
- Edit group information, subject to permissions.
- Add or remove group members.
- Promote or remove group administrators.
- Configure whether non-admin members may edit group information.
- Leave a group; delete a group where permitted.

### 📞 Audio & Video Calling

- Make one-to-one audio and video calls through ZEGOCLOUD.
- Invite group members to group audio and video calls.
- Show call entries in one-to-one chat history.
- Add group call activity messages when invitations are sent successfully.

### 👤 Profile

- View profile name, email address, profile image, and joined date.
- Select a new profile picture from the device gallery.
- Upload profile pictures to Supabase Storage.
- Update the profile image URL in Cloud Firestore.
- Manage sign-out with a confirmation dialog.

### 🔔 Notifications

- Integrate Firebase Cloud Messaging (FCM) and local notification handling.
- Maintain the device messaging token in Firestore.
- Invoke a Supabase Edge Function to request push notifications for supported chat events.

> Push notification delivery depends on Firebase, device permissions, and correct deployment of the Supabase Edge Function.

---

## 🏗️ Architecture

Connecto uses a **feature-based folder structure**. UI, models, providers, and services are grouped by application feature, with shared functionality in `core/`.

```text
lib/
├── app/
│   ├── app.dart
│   ├── app_state_manager.dart
│   └── auth_wrapper.dart
│
├── core/
│   ├── config/                  # ZEGOCLOUD configuration
│   ├── services/                # Notifications and shared services
│   ├── theme/                   # App colors and Material theme
│   ├── utils/                   # Formatting and chat helpers
│   └── widgets/                 # Reusable widgets
│
├── features/
│   ├── auth/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── services/
│   ├── chat/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── groups/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   └── profile/
│       ├── models/
│       ├── providers/
│       └── screens/
│
├── firebase_options.dart
└── main.dart
```

---

## 🧠 State Management

The app uses **Riverpod** (`flutter_riverpod`) to separate application state from the UI and react to changes in authentication and Firestore data.

| Provider / Notifier | Responsibility |
|---|---|
| `authStateProvider` | Listen to Firebase authentication state and keep the login session synchronized |
| `authFormProvider` | Manage authentication form fields and loading/validation state |
| `usersProvider` | Load registered users |
| `searchQueryProvider` / `filteredUsersProvider` | Filter the user list by search text |
| `requestProvider` | Manage pending message requests |
| `chatsProvider` | Stream and display the user's private conversations |
| `typingProvider` | Observe typing status in a conversation |
| Group chat providers | Read group conversations and typing state |
| `profileProvider` | Load and update profile data and images |

Real-time updates are powered by Firestore streams. Authentication controls the root screen through `AuthGate`, so signed-in users return to the app without repeating the Google sign-in flow.

---

## 🔥 Firebase Integration

Firebase provides authentication and the real-time database used by Connecto.

### Firebase Authentication

- Email/password sign-up and login.
- Google Sign-In.
- Persistent authentication sessions and sign-out.
- Auth-state updates for app navigation and call-service initialization.

### Cloud Firestore

| Collection / Path | Data |
|---|---|
| `users` | User profiles, presence, and messaging tokens |
| `messageRequests` | Pending and accepted/rejected contact requests |
| `friendships` | Connections between users |
| `chats` | One-to-one conversation metadata and unread counts |
| `messages` | Private text, image, and call-history messages |
| `groups` | Group names, members, admins, permissions, and unread counts |
| `groupMessages` | Group text, image, and system messages |
| `users/{uid}/notifications` | Notification records associated with a user |

### Firebase Cloud Messaging

- Requests notification permission.
- Retrieves and refreshes FCM device tokens.
- Handles foreground notifications with local notification support.
- Works with a Supabase Edge Function for server-side push requests.

---

## 🖼️ Supabase Storage

Supabase Storage is used for chat images and profile pictures.

**Storage bucket:** `chat_files`

**Stored media:**

- Shared chat and group images.
- Profile pictures under a `profile_pictures/` path.

### Image Upload Flow

1. The user selects an image from the device gallery.
2. The app uploads the file to the `chat_files` Supabase Storage bucket.
3. Supabase provides a public file URL.
4. The URL is saved with the relevant Firestore message or user profile.
5. The image is displayed in chat or profile screens.

### Supabase Edge Functions

The `send-user-notification` Edge Function is invoked from the Flutter app for notification requests. Its server-side implementation must be deployed and configured separately.

---

## 📞 ZEGOCLOUD Calling

Connecto integrates **ZEGOCLOUD Prebuilt Call UI Kit** and the **signaling plugin** for one-to-one and group audio/video calls.

- Initializes the invitation service for the authenticated Firebase user.
- Uses the Firebase user ID as the calling user ID.
- Provides audio and video invitation buttons in private chats and groups.
- Cleans up the calling service when the user logs out.

Calling requires valid ZEGOCLOUD app configuration and the relevant signaling/call services to be available.

---

## 📦 Dependencies

These libraries are used in the supplied `lib/` source. See `pubspec.yaml` for the versions installed in the full Flutter project.

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management and reactive providers |
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Email/password and Google credential authentication |
| `cloud_firestore` | Real-time chats, groups, requests, and user data |
| `google_sign_in` | Google account selection and sign-in |
| `firebase_messaging` | FCM device tokens and message handling |
| `flutter_local_notifications` | Display notifications on the device |
| `supabase_flutter` | Image uploads and Edge Function invocation |
| `image_picker` | Select chat and profile images |
| `zego_uikit_prebuilt_call` | Prebuilt audio/video calling |
| `zego_uikit_signaling_plugin` | Call invitations and signaling |
| `zego_uikit` | ZEGOCLOUD UI/user integration |
| `permission_handler` | Camera, microphone, and notification permissions |
| `intl` | Date and time formatting |
| `cherry_toast` | UI notification/toast messages |

---

## 🎨 UI Design

The app uses a custom **Modern Minimal Blue** design with Flutter Material 3.

- Blue primary actions and light-blue highlights.
- White surfaces with soft gray backgrounds.
- Rounded cards, text fields, and chat bubbles.
- Clear incoming/outgoing message styling.
- Bottom navigation for **Chats**, **Groups**, **Users**, and **Profile**.
- Responsive screens built with Flutter widgets.

Theme definitions are in `lib/core/theme/app_colors.dart`.

---

## 🚀 Getting Started



### 1. Clone the Repository

```bash
git clone https://github.com/AliZaidiSyed/Chat_App.git
cd Chat_App
```

### 2. Install Dependencies

```bash
flutter pub get
```


### 4. Run the Application

```bash
flutter run
```





## 👨‍💻 Developer

**Muhammad Ali**  
Flutter Developer  
GitHub: [AliZaidiSyed](https://github.com/AliZaidiSyed)

---

<div align="center">

### Made with Flutter

**Connecto - Flutter Chat App**

</div>
