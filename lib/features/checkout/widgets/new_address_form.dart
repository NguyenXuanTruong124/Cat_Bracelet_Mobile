import 'package:flutter/material.dart';

class NewAddressForm extends StatelessWidget {
  final TextEditingController receiverController;
  final TextEditingController phoneController;
  final TextEditingController detailController;

  final List<dynamic> provinces;
  final List<dynamic> districts;
  final List<dynamic> wards;

  final dynamic selectedProvince;
  final dynamic selectedDistrict;
  final dynamic selectedWard;

  final ValueChanged<dynamic> onProvinceChanged;
  final ValueChanged<dynamic> onDistrictChanged;
  final ValueChanged<dynamic> onWardChanged;

  const NewAddressForm({
    super.key,
    required this.receiverController,
    required this.phoneController,
    required this.detailController,
    required this.provinces,
    required this.districts,
    required this.wards,
    required this.selectedProvince,
    required this.selectedDistrict,
    required this.selectedWard,
    required this.onProvinceChanged,
    required this.onDistrictChanged,
    required this.onWardChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _field(
          receiverController,
          'Người nhận',
        ),

        _field(
          phoneController,
          'Số điện thoại',
        ),

        // dropdown province

        // dropdown district

        // dropdown ward

        _field(
          detailController,
          'Địa chỉ chi tiết',
        ),
      ],
    );
  }

  Widget _field(
      TextEditingController controller,
      String label,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border:
          const OutlineInputBorder(),
        ),
      ),
    );
  }
}