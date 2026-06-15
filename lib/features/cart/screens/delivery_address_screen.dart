import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../profile/models/user_session.dart';
import '../../../core/services/api_helpers.dart';
import '../../../core/theme/app_colors.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
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
        _addresses = decodeListPayload(jsonDecode(response.body))
            .whereType<Map<String, dynamic>>()
            .where(
              (a) => (a['status'] ?? '').toString().toUpperCase() == 'ACTIVE',
            )
            .toList();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setDefault(String addressId) async {
    final user = UserSession.currentUser;
    if (user == null) return;

    final baseUrl = ApiConfig.getBaseUrl(context);
    final response = await http.patch(
      Uri.parse('$baseUrl/user-address/${user.id}/$addressId/default'),
      headers: apiHeaders(json: true),
    );

    if (response.statusCode == 200) {
      await _fetchAddresses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đặt làm địa chỉ mặc định')),
        );
      }
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    final user = UserSession.currentUser;
    if (user == null) return;

    final baseUrl = ApiConfig.getBaseUrl(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa địa chỉ'),
        content: const Text('Bạn có chắc muốn xóa địa chỉ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final response = await http.delete(
      Uri.parse('$baseUrl/user-address/${user.id}/$addressId'),
      headers: apiHeaders(),
    );

    if (response.statusCode == 200) {
      await _fetchAddresses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa địa chỉ')),
        );
      }
    }
  }

  Future<void> _openForm({Map<String, dynamic>? address}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressFormScreen(address: address),
      ),
    );
    if (saved == true) _fetchAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text(
          'ĐỊA CHỈ GIAO HÀNG',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openForm(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Thêm địa chỉ'),
            ),
      body: user == null
          ? const Center(child: Text('Vui lòng đăng nhập'))
          : _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _addresses.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _fetchAddresses,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                itemCount: _addresses.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _AddressCard(
                    address: _addresses[index],
                    onEdit: () => _openForm(address: _addresses[index]),
                    onDelete: () =>
                        _deleteAddress(_addresses[index]['id'].toString()),
                    onSetDefault: () =>
                        _setDefault(_addresses[index]['id'].toString()),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 64,
              color: AppColors.outlineVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có địa chỉ giao hàng',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thêm địa chỉ để đặt hàng nhanh hơn',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Map<String, dynamic> address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final isDefault = address['isDefault'] == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault
              ? AppColors.primaryContainer.withValues(alpha: 0.4)
              : AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  address['receiverName']?.toString() ?? 'Người nhận',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Mặc định',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            address['phone']?.toString() ?? '',
            style: const TextStyle(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.home_outlined, size: 18, color: AppColors.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${address['detailAddress'] ?? ''}, ${address['ward'] ?? ''}, ${address['district'] ?? ''}, ${address['province'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (!isDefault)
                TextButton.icon(
                  onPressed: onSetDefault,
                  icon: const Icon(Icons.star_outline, size: 18),
                  label: const Text('Đặt mặc định'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                  ),
                ),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                tooltip: 'Sửa',
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Xóa',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddressFormScreen extends StatefulWidget {
  final Map<String, dynamic>? address;

  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _receiverController = TextEditingController();
  final _phoneController = TextEditingController();
  final _detailController = TextEditingController();

  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _wards = [];

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;
  bool _isDefault = false;
  bool _isLoading = false;
  bool _loadingLocations = true;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final a = widget.address!;
      _receiverController.text = a['receiverName']?.toString() ?? '';
      _phoneController.text = a['phone']?.toString() ?? '';
      _detailController.text = a['detailAddress']?.toString() ?? '';
      _selectedProvince = a['province']?.toString();
      _selectedDistrict = a['district']?.toString();
      _selectedWard = a['ward']?.toString();
      _isDefault = a['isDefault'] == true;
    }
    _loadProvinces();
  }

  @override
  void dispose() {
    _receiverController.dispose();
    _phoneController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _loadProvinces() async {
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.get(Uri.parse('$baseUrl/shipments/provinces'));
      if (response.statusCode == 200) {
        _provinces = decodeListPayload(jsonDecode(response.body))
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    } finally {
      if (mounted) setState(() => _loadingLocations = false);
    }
  }

  Future<void> _loadDistricts(String provinceId) async {
    final baseUrl = ApiConfig.getBaseUrl(context);
    final response = await http.get(
      Uri.parse('$baseUrl/shipments/districts$provinceId'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _districts = decodeListPayload(jsonDecode(response.body))
            .whereType<Map<String, dynamic>>()
            .toList();
        _wards = [];
        _selectedDistrict = null;
        _selectedWard = null;
      });
    }
  }

  Future<void> _loadWards(String districtId) async {
    final baseUrl = ApiConfig.getBaseUrl(context);
    final response = await http.get(
      Uri.parse('$baseUrl/shipments/wards$districtId'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _wards = decodeListPayload(jsonDecode(response.body))
            .whereType<Map<String, dynamic>>()
            .toList();
        _selectedWard = null;
      });
    }
  }

  Future<void> _save() async {
    final user = UserSession.currentUser;
    if (user == null) return;

    final receiver = _receiverController.text.trim();
    final phone = _phoneController.text.trim();
    final detail = _detailController.text.trim();

    if ([receiver, phone, detail, _selectedProvince, _selectedDistrict, _selectedWard]
        .any((v) => v == null || v.toString().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final body = jsonEncode({
        'receiverName': receiver,
        'phone': phone,
        'province': _selectedProvince,
        'district': _selectedDistrict,
        'ward': _selectedWard,
        'detailAddress': detail,
        'isDefault': _isDefault,
        'status': 'ACTIVE',
      });

      final http.Response response;
      if (_isEditing) {
        response = await http.patch(
          Uri.parse(
            '$baseUrl/user-address/${user.id}/${widget.address!['id']}',
          ),
          headers: apiHeaders(json: true),
          body: body,
        );
      } else {
        response = await http.post(
          Uri.parse('$baseUrl/user-address/${user.id}'),
          headers: apiHeaders(json: true),
          body: body,
        );
      }

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${response.statusCode}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text(
          _isEditing ? 'Sửa địa chỉ' : 'Thêm địa chỉ',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loadingLocations
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _field(_receiverController, 'Người nhận', Icons.person_outline),
                _field(_phoneController, 'Số điện thoại', Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                _locationDropdown(
                  label: 'Tỉnh/Thành phố',
                  value: _selectedProvince,
                  items: {
                    ..._provinces.map((p) => p['name']?.toString() ?? ''),
                    if (_selectedProvince != null &&
                        !_provinces.any((p) => p['name'] == _selectedProvince))
                      _selectedProvince!,
                  }.toList(),
                  onChanged: (name) async {
                    setState(() => _selectedProvince = name);
                    final province = _provinces.cast<Map<String, dynamic>?>().firstWhere(
                          (p) => p?['name'] == name,
                          orElse: () => null,
                        );
                    if (province != null) {
                      await _loadDistricts(province['id'].toString());
                    }
                  },
                ),
                _locationDropdown(
                  label: 'Quận/Huyện',
                  value: _selectedDistrict,
                  items: {
                    ..._districts.map((d) => d['name']?.toString() ?? ''),
                    if (_selectedDistrict != null &&
                        !_districts.any((d) => d['name'] == _selectedDistrict))
                      _selectedDistrict!,
                  }.toList(),
                  onChanged: (name) async {
                    setState(() => _selectedDistrict = name);
                    final district = _districts.cast<Map<String, dynamic>?>().firstWhere(
                          (d) => d?['name'] == name,
                          orElse: () => null,
                        );
                    if (district != null) {
                      await _loadWards(district['id'].toString());
                    }
                  },
                ),
                _locationDropdown(
                  label: 'Phường/Xã',
                  value: _selectedWard,
                  items: {
                    ..._wards.map((w) => w['name']?.toString() ?? ''),
                    if (_selectedWard != null &&
                        !_wards.any((w) => w['name'] == _selectedWard))
                      _selectedWard!,
                  }.toList(),
                  onChanged: (name) => setState(() => _selectedWard = name),
                ),
                _field(_detailController, 'Địa chỉ chi tiết', Icons.home_outlined),
                SwitchListTile(
                  value: _isDefault,
                  onChanged: (v) => setState(() => _isDefault = v),
                  title: const Text('Đặt làm địa chỉ mặc định'),
                  activeThumbColor: AppColors.primary,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isEditing ? 'CẬP NHẬT' : 'LƯU ĐỊA CHỈ',
                            style: const TextStyle(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.secondary),
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _locationDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
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
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
