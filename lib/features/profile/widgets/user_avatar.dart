import 'package:flutter/material.dart';
import '../../../config/api_config.dart';
import '../../../core/services/api_helpers.dart';

class UserAvatar extends StatelessWidget {
  final String avatarUrl;

  const UserAvatar({super.key, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = avatarUrl.isNotEmpty
        ? buildImageUrl(ApiConfig.getBaseUrl(context), avatarUrl)
        : '';

    return CircleAvatar(
      radius: 46,
      backgroundImage: resolvedUrl.isNotEmpty
          ? NetworkImage(resolvedUrl)
          : null,
      child: resolvedUrl.isEmpty ? const Icon(Icons.person, size: 44) : null,
    );
  }
}
