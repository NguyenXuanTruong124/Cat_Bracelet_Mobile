import 'package:flutter/material.dart';

class UserInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final String email;

  const UserInfoForm({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _field(nameController, 'Họ tên', Icons.person),
        _field(phoneController, 'Số điện thoại', Icons.phone),
        _readOnlyField(email, 'Email', Icons.email),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _readOnlyField(String value, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
