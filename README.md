<div align="center">

# Connecto - Flutter Chat App
### A Real-Time Messaging and Calling Application Built with Flutter

## 🛠️ Tech Stack

![Flutter](https://img.shields.io/badge/Flutter-Mobile_Development-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-Programming_Language-0175C2?logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-State_Management-6750A4)
![Firebase](https://img.shields.io/badge/Firebase-Authentication_%26_Firestore-FFCA28?logo=firebase&logoColor=black)
![Google Sign-In](https://img.shields.io/badge/Google-Sign_In-4285F4?logo=google&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Storage_%26_Edge_Functions-3ECF8E?logo=supabase&logoColor=white)
![ZEGOCLOUD](https://img.shields.io/badge/ZEGOCLOUD-Audio_%26_Video_Calls-2563EB)
![FCM](https://img.shields.io/badge/FCM-Push_Notifications-FF6F00?logo=firebase&logoColor=white)




</div>

Connecto is a Flutter chat application for discovering users, communicating through private and group conversations, sharing images, and making audio/video calls. It uses Firebase for authentication and real-time data, Supabase for media storage, Riverpod for state management, and ZEGOCLOUD for calls.

---

## 📱 Screenshots

The following screenshots show the main Connecto features, from authentication and chat screens to group management and calling.

<div align="center">
<img width="1540" height="4054" alt="Connecto_GitHub_All_Features" src="https://github.com/user-attachments/assets/f4f3981a-b8f9-438e-82c8-0814bcf0a06c" />



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



---


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
