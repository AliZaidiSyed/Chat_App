# chat_app

A real-time messaging application built with **Flutter and Dart**, designed for private one-to-one conversations and group communication. The app combines Firebase services for authentication, live chat data, and push notifications and Supabase Storage for image uploads. It also integrates ZEGOCLOUD for audio and video call invitations.

**Key Features**

- **Authentication:** Create an account and sign in with email and password and Google Sign-In. The app also manages the authenticated user's session and sign-out flow.
- **User Profiles:** View profile information and update a profile picture. User presence and last-seen information are maintained in Firestore.
- **Friend Requests:** Send, receive, accept, or reject message requests. A one-to-one friendship and chat are created after a request is accepted.
- **One-to-One Messaging:** Exchange messages in real time using Cloud Firestore, with support for text messages and image messages with optional captions.
- **Chat Activity:** View recent conversations, latest-message previews, timestamps, and unread-message counts.
- **Messaging Indicators:** See typing activity, message read indicators, and online/offline status.
- **Group Conversations:** Create groups with a name and optional group picture, add friends, and exchange text and image messages.
- **Group Administration:** View group information and members, manage administrators, add or remove members, control who can edit group information, leave a group, or delete a group.
- **Group Activity:** View group message updates, typing indicators, unread counts, and system messages for group events such as member changes.
- **Audio and Video Calls:** Send one-to-one and group audio/video call invitations using ZEGOCLOUD.
- **Push Notifications:** Receive notifications for direct messages, group messages, and friend requests through Firebase Cloud Messaging, with foreground notification display handled by local notifications.

**Technology Stack**

| Area | Technology |
| --- | --- |
| App development | Flutter, Dart |
| State management | Riverpod |
| Authentication | Firebase Authentication, Google Sign-In |
| Real-time database | Cloud Firestore |
| Push notifications | Firebase Cloud Messaging, Flutter Local Notifications |
| Image and file storage | Supabase Storage |
| Audio/video calling | ZEGOCLOUD UI Kit and Signaling Plugin |
| Device features | Image Picker, Permission Handler |

**Application Structure**

The code is organized into feature-based folders to keep UI, state, data models, and backend operations separate:

- `lib/auth/` — sign-up and sign-in screens and authentication models.
- `lib/chat/` — one-to-one chat screens, user and message models, Riverpod providers, and chat services.
- `lib/group_ chats/` — group chat screens, group models, providers, administration widgets, and group chat services.
- `lib/core/` — shared helpers, utilities, and notification handling.
- `lib/services/` — authentication services and related providers.
- `lib/wrapper_state/` — authentication and application state wrappers.










# Project Screenshots

<img width="1480" height="6450" alt="connecto_github_screenshots_no_header" src="https://github.com/user-attachments/assets/8401fca3-9d0c-4ead-bfce-bc1c910171a2" />









## Repository

Find the source code and project updates on GitHub:

**[AliZaidiSyed/Chat_App](https://github.com/AliZaidiSyed/Chat_App)**
