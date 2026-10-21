# Connecto — Real-Time Chat App

Connecto is a Flutter-based messaging application designed to help users discover other users and chat in real time. It uses Firebase Authentication for Google sign-in, Cloud Firestore for user and message data, and Supabase Storage for sharing images and voice notes.

## Features

- **Google Sign-In** — sign in with a Google account through Firebase Authentication.
- **User Profiles** — view profile details, including name, email, and profile image.
- **User Search** — search for other registered users by username.
- **Real-Time Chat** — send and receive text messages with live updates from Cloud Firestore.
- **Image Sharing** — choose an image from the device gallery and share it in a chat.
- **Voice Notes** — record, upload, and play audio messages.
- **Recent Chat Details** — display the latest message and its timestamp in the chat list.
- **Session Preferences** — store basic signed-in user details locally with `shared_preferences`.
- **Account Actions** — sign out or use the delete-account option from the profile screen.

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter & Dart | Mobile app UI and application logic |
| Firebase Authentication | Google sign-in and user authentication |
| Cloud Firestore | User records, chat rooms, messages, and real-time updates |
| Supabase Storage | Image and audio file storage |
| `google_sign_in` | Google account sign-in flow |
| `image_picker` | Select images from the device gallery |
| `flutter_sound` | Record voice notes |
| `audioplayers` | Play recorded audio messages |
| `shared_preferences` | Save basic user details locally |
| `permission_handler` | Request microphone permission |
| `path_provider` | Access a temporary directory for audio recording |
| `intl` | Format message timestamps |

## How It Works

1. A user signs in with Google.
2. Connecto saves the user's basic information in Cloud Firestore and local preferences.
3. The user searches for another registered username and opens a chat.
4. Text messages are saved in the chat room's `chats` subcollection and displayed through Firestore snapshots.
5. Images and audio files are uploaded to the Supabase Storage bucket named `chat_files`; their URLs and message details are saved in Firestore.
6. The chat list uses the latest-message fields stored on each chat room to show recent activity.




## Project Structure

```text
Chat_App/
├── assets/
│   └── images/
├── lib/
│   ├── Pages/
│   │   ├── chat_page.dart
│   │   ├── home.dart
│   │   ├── onboard.dart
│   │   └── profile.dart
│   ├── services/
│   │   ├── auth.dart
│   │   ├── database.dart
│   │   └── shared_pref.dart
│   ├── firebase_options.dart
│   └── main.dart
├── android/
├── ios/
├── web/
├── windows/
├── pubspec.yaml
└── README.md
```



## Author

**Ali Zaidi**  
GitHub: [AliZaidiSyed](https://github.com/AliZaidiSyed)

---

Built with Flutter, Firebase, and Supabase.
