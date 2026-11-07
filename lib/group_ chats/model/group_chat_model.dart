class GroupModel {
  final String groupId;
  final String groupName;
  final String? groupPhotoURL;
  final String? callInitiatorId;
  final List<String> members; // All member UIDs
  final List<String> admins; // Admin UIDs
  final String createdBy;
  final DateTime createdAt;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final bool anyoneCanEditInfo; // Toggle for group info editing
  final Map<String, int> unreadCount;

  GroupModel({
    required this.groupId,
    required this.groupName,
    this.callInitiatorId,
    this.groupPhotoURL,
    required this.members,
    required this.admins,
    required this.createdBy,
    required this.createdAt,
    this.lastMessage = '',
    this.lastMessageTime,
    this.anyoneCanEditInfo = false,
    this.unreadCount = const {},
  });

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      groupId: map['groupId'] ?? '',
      callInitiatorId: map['callInitiatorId'] ?? '',
      groupName: map['groupName'] ?? '',
      groupPhotoURL: map['groupPhotoURL'],
      members: List<String>.from(map['members'] ?? []),
      admins: List<String>.from(map['admins'] ?? []),
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime']?.toDate(),
      anyoneCanEditInfo: map['anyoneCanEditInfo'] ?? false,
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
    ); // GroupModel
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'groupPhotoURL': groupPhotoURL,
      'members': members,
      'admins': admins,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'callInitiatorId': callInitiatorId,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'anyoneCanEditInfo': anyoneCanEditInfo,
      'unreadCount': unreadCount,
    };
  }

  bool isAdmin(String userId) => admins.contains(userId);
  bool isMember(String userId) => members.contains(userId);

  //add helper method  to get unread count for a user
int getUnreadCount(String userId)=> unreadCount[userId]??0;
}