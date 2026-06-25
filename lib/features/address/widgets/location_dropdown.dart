import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class LocationDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const LocationDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: items.contains(value) ? value : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: items
            .map((e) => DropdownMenuItem(
          value: e,
          child: Text(e),
        ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}