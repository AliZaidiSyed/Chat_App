import 'dart:io';

import 'package:chat_app/chat/provider/proviider.dart';
import 'package:chat_app/core/utils/utils.dart';
import 'package:chat_app/group_%20chats/provider/group_chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  bool _isCreated = false;
  final _selectedMembers = <String>{};
  File? _groupImage;

  final _nameController = TextEditingController();

  //to pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _groupImage = File(pickedFile.path);
      });
    }
  }

  // method to create a group

  Future<void> _createGroup() async {
    if (_nameController.text.trim().isEmpty) {
      showAppSnackbar(
        context: context,
        type: SnackbarType.error,
        description: "Please Enter Group Name",
      );
      return;
    }
    if (_selectedMembers.isEmpty) {
      showAppSnackbar(
        context: context,
        type: SnackbarType.error,
        description: "Please select at least one member other than you",
      );
      return;
    }
    setState(() => _isCreated = true);
    final chatService = ref.read(groupChatServiceProvider);
    String? photoURL;

    //upload group image if selected
    if (_groupImage != null) {
      photoURL = await chatService.uploadImage(
          _groupImage!, "group_${DateTime.now().millisecondsSinceEpoch}");
    }

    final result = await chatService.createGroup(
      groupName: _nameController.text.trim(),
      memberIds: _selectedMembers.toList(),
      groupPhotoURL: photoURL,
    );

    setState(() => _isCreated = false);
    if (result == "success" && mounted) {
   //   ref.invalidate(groupProvider);
      Navigator.pop(context);
      showAppSnackbar(
        context: context,
        type: SnackbarType.success,
        description: "Group created successfully",
      );
    } else if (mounted) {
      showAppSnackbar(
        context: context,
        type: SnackbarType.error,
        description: result,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Group"),
        actions: [
          if (_isCreated)
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
                onPressed: () {
                  _createGroup();
                },
                child: Text("Create")),
        ],
      ),
      body: Column(
        children: [
          //group profile image
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                  _groupImage != null ? FileImage(_groupImage!) : null,
                  child: _groupImage == null
                      ? Icon(Icons.group, size: 50, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          //group name
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Group Name",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Members (Friends Only)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          SizedBox(
            height: 16,
          ),
          //member selection
          Expanded(
            child: users.when(
              data: (userList) {
                if (userList.isEmpty) {
                  return Center(
                    child: Text("No friends available"),
                  );
                }
                return ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    final user = userList[index];
                    final isSelected = _selectedMembers.contains(user.uid);
                    return FutureBuilder<bool>(
                      future: ref
                          .read(groupChatServiceProvider)
                          .areUserFriends(
                          ref.read(groupChatServiceProvider).currentUserId,
                          user.uid),
                      builder: (context, snapshot) {
                        if (snapshot.data != true) return SizedBox();
                        return CheckboxListTile.adaptive(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedMembers.add(user.uid);
                              } else {
                                _selectedMembers.remove(user.uid);
                              }
                            });
                          },
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          secondary: CircleAvatar(
                            backgroundImage: user.photoURL != null
                                ? NetworkImage(user.photoURL!)
                                : null,
                            child: user.photoURL == null
                                ? Text(user.name[0].toUpperCase())
                                : null,
                          ),
                        );
                      },
                    );
                  },
                );
              },
              error: (error, _) => Center(
                child: Text("Error $error"),
              ),
              loading: () => Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        ],
      ),
    );
  }
}