import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../models/user_session.dart';
import '../services/api_helpers.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color _wine = Color(0xFF902021);

  final _voucherController = TextEditingController();
  final _receiverController = TextEditingController();
  final _phoneController = TextEditingController();
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _wardController = TextEditingController();
  final _detailController = TextEditingController();

  List<Map<String, dynamic>> _addresses = [];
  String? _selectedAddressId;
  bool _isLoading = true;
  bool _showNewAddressForm = false;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  @override
  void dispose() {
    _voucherController.dispose();
    _receiverController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _fetchAddresses() async {
    final user = UserSession.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.get(
        Uri.parse('$baseUrl/user-address/${user.id}'),
        headers: apiHeaders(),
      );
      if (response.statusCode == 200) {
        final addresses = decodeListPayload(jsonDecode(response.body))
            .whereType<Map<String, dynamic>>()
            .where(
              (address) =>
                  (address['status'] ?? '').toString().toLowerCase() ==
                  'active',
            )
            .toList();
        _addresses = addresses;
        _selectedAddressId = addresses
            .cast<Map<String, dynamic>?>()
            .firstWhere(
              (address) => address?['isDefault'] == true,
              orElse: () => addresses.isEmpty ? null : addresses.first,
            )?['id']
            ?.toString();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showNewAddressForm = _addresses.isEmpty;
        });
      }
    }
  }

  Future<String?> _createAddressIfNeeded() async {
    final user = UserSession.currentUser;
    if (user == null) {
      return null;
    }
    if (!_showNewAddressForm) {
      return _selectedAddressId;
    }

    final receiver = _receiverController.text.trim();
    final phone = _phoneController.text.trim();
    final province = _provinceController.text.trim();
    final district = _districtController.text.trim();
    final ward = _wardController.text.trim();
    final detail = _detailController.text.trim();

    if ([
      receiver,
      phone,
      province,
      district,
      ward,
      detail,
    ].any((value) => value.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhap day du dia chi giao hang')),
      );
      return null;
    }

    final baseUrl = ApiConfig.getBaseUrl(context);
    final response = await http.post(
      Uri.parse('$baseUrl/user-address/${user.id}'),
      headers: apiHeaders(json: true),
      body: jsonEncode({
        'receiverName': receiver,
        'phone': phone,
        'province': province,
        'district': district,
        'ward': ward,
        'detailAddress': detail,
        'isDefault': _addresses.isEmpty,
        'status': 'ACTIVE',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded['id']?.toString();
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tao dia chi loi: ${response.statusCode}')),
      );
    }
    return null;
  }

  Future<void> _checkout() async {
    final user = UserSession.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui long dang nhap')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final addressId = await _createAddressIfNeeded();
      if (addressId == null) {
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/orders/checkout'),
        headers: apiHeaders(json: true),
        body: jsonEncode({
          'userId': user.id,
          'addressId': addressId,
          'voucherCode': _voucherController.text.trim(),
          'paymentReturnUrl': dotenv.env['PAYOS_RETURN_URL'],
          'paymentCancelUrl': dotenv.env['PAYOS_CANCEL_URL'],
        }),
      );

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final checkoutUrl = _extractCheckoutUrl(decoded);
        final order = _extractOrder(decoded);

        if (checkoutUrl != null) {
          await _openPaymentLink(checkoutUrl);
        }

        if (!mounted) {
          return;
        }

        Navigator.pushReplacementNamed(
          context,
          '/payment',
          arguments: {
            'order': order,
            'checkoutUrl': checkoutUrl,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loi dat hang: ${response.statusCode}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openPaymentLink(String checkoutUrl) async {
    final uri = Uri.tryParse(checkoutUrl);
    if (uri == null) {
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khong mo duoc cong thanh toan PayOS')),
      );
    }
  }

  Map<String, dynamic>? _extractOrder(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final data = decoded['data'];
    final order = decoded['order'];
    if (order is Map<String, dynamic>) {
      return order;
    }
    if (data is Map<String, dynamic>) {
      final nestedOrder = data['order'];
      if (nestedOrder is Map<String, dynamic>) {
        return nestedOrder;
      }
      return data;
    }
    return decoded;
  }

  String? _extractCheckoutUrl(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    for (final key in [
      'checkoutUrl',
      'checkout_url',
      'paymentUrl',
      'payment_url',
      'payosCheckoutUrl',
      'payos_checkout_url',
    ]) {
      final value = decoded[key]?.toString();
      if (value != null && value.startsWith('http')) {
        return value;
      }
    }

    final data = decoded['data'];
    final order = decoded['order'];
    if (data is Map<String, dynamic>) {
      return _extractCheckoutUrl(data);
    }
    if (order is Map<String, dynamic>) {
      return _extractCheckoutUrl(order);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dat hang'),
        backgroundColor: _wine,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _wine))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Dia chi giao hang',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (_addresses.isNotEmpty) ...[
                  ..._addresses.map(_addressTile),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _showNewAddressForm = true);
                    },
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('Them dia chi moi'),
                  ),
                ],
                if (_showNewAddressForm) _newAddressForm(),
                const SizedBox(height: 16),
                TextField(
                  controller: _voucherController,
                  decoration: const InputDecoration(
                    labelText: 'Voucher code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _wine,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _checkout,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Xac nhan dat hang'),
                ),
              ],
            ),
    );
  }

  Widget _addressTile(Map<String, dynamic> address) {
    final id = address['id']?.toString();
    final selected = id == _selectedAddressId && !_showNewAddressForm;

    return Card(
      color: selected ? const Color(0xFFFFF8F7) : null,
      child: ListTile(
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? _wine : null,
        ),
        onTap: () {
          setState(() {
            _selectedAddressId = id;
            _showNewAddressForm = false;
          });
        },
        title: Text(address['receiverName']?.toString() ?? 'Nguoi nhan'),
        subtitle: Text(
          '${address['phone'] ?? ''}\n${address['detailAddress'] ?? ''}, ${address['ward'] ?? ''}, ${address['district'] ?? ''}, ${address['province'] ?? ''}',
        ),
      ),
    );
  }

  Widget _newAddressForm() {
    return Column(
      children: [
        _field(_receiverController, 'Nguoi nhan'),
        _field(_phoneController, 'So dien thoai'),
        _field(_provinceController, 'Tinh/Thanh pho'),
        _field(_districtController, 'Quan/Huyen'),
        _field(_wardController, 'Phuong/Xa'),
        _field(_detailController, 'Dia chi chi tiet'),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
