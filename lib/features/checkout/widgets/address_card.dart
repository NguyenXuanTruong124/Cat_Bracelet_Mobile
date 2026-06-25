import 'package:flutter/material.dart';

import '../models/address_model.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final bool selected;
  final VoidCallback onTap;

  const AddressCard({
    super.key,
    required this.address,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected
          ? const Color(0xFFFFF8F7)
          : null,
      child: ListTile(
        leading: Icon(
          selected
              ? Icons.radio_button_checked
              : Icons.radio_button_off,
        ),
        onTap: onTap,
        title: Text(
          address.receiverName,
        ),
        subtitle: Text(
          [
            address.phone,
            address.detailAddress,
            address.ward,
            address.district,
            address.province,
          ].join(', '),
        ),
      ),
    );
  }
}