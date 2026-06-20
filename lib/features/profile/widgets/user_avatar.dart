import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String avatarUrl;

  const UserAvatar({super.key, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 46,
      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
      child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 44) : null,
    );
  }
}
