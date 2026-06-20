import 'package:flutter/material.dart';

import '../models/shipping_address_model.dart';

class ShippingAddressCard extends StatelessWidget {
  final ShippingAddressModel address;

  const ShippingAddressCard({
    super.key,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '${address.receiverName} - ${address.phone}\n'
              '${address.fullAddress}',
        ),
      ),
    );
  }
}