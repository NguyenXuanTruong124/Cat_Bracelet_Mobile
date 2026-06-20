import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/config/api_config.dart';
import '/features/profile/models/user_session.dart';
import '../../../core/services/api_helpers.dart';
import '../../../core/theme/app_colors.dart';
import '../services/address_service.dart';
import '../widgets/address_text_field.dart';
import '../widgets/location_dropdown.dart';

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
    _initForm();
  }

  Future<void> _initForm() async {
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

    _provinces = await AddressService.getProvinces(context);

    if (_isEditing) {
      final province = _provinces.cast<Map<String, dynamic>?>().firstWhere(
            (p) => p?['name'] == _selectedProvince,
        orElse: () => null,
      );

      if (province != null) {
        await _loadDistrictsForEdit(province['id'].toString());

        final district = _districts.cast<Map<String, dynamic>?>().firstWhere(
              (d) => d?['name'] == _selectedDistrict,
          orElse: () => null,
        );

        if (district != null) {
          await _loadWardsForEdit(district['id'].toString());
        }
      }
    }

    if (mounted) {
      setState(() {
        _loadingLocations = false;
      });
    }
  }

  Future<void> _loadDistrictsForEdit(String provinceId) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.get(
      Uri.parse('$baseUrl/shipments/districts/$provinceId'),
    );

    if (response.statusCode == 200) {
      _districts = decodeListPayload(
        jsonDecode(response.body),
      ).whereType<Map<String, dynamic>>().toList();
    }
  }

  Future<void> _loadWardsForEdit(String districtId) async {
    final baseUrl = ApiConfig.getBaseUrl(context);

    final response = await http.get(
      Uri.parse('$baseUrl/shipments/wards/$districtId'),
    );

    if (response.statusCode == 200) {
      _wards = decodeListPayload(
        jsonDecode(response.body),
      ).whereType<Map<String, dynamic>>().toList();
    }
  }

  @override
  void dispose() {
    _receiverController.dispose();
    _phoneController.dispose();
    _detailController.dispose();
    super.dispose();
  }



  Future<void> _save() async {
    final user = UserSession.currentUser;
    if (user == null) return;

    final receiver = _receiverController.text.trim();
    final phone = _phoneController.text.trim();
    final detail = _detailController.text.trim();

    if ([
      receiver,
      phone,
      detail,
      _selectedProvince,
      _selectedDistrict,
      _selectedWard,
    ].any((v) =>
    v == null || v
        .toString()
        .isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
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
        response = await AddressService.updateAddress(
          context,
          user.id.toString(),
          widget.address!['id'].toString(),
          body,
        );
      } else {
        response = await AddressService.createAddress(
          context,
          user.id.toString(),
          body,
        );
      }

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${response.statusCode}')));
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
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AddressTextField(
            controller: _receiverController,
            label: 'Người nhận',
            icon: Icons.person_outline,
          ),
          AddressTextField(
            controller: _phoneController,
            label: 'Số điện thoại',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          LocationDropdown(
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
              final province = _provinces
                  .cast<Map<String, dynamic>?>()
                  .firstWhere(
                    (p) => p?['name'] == name,
                orElse: () => null,
              );
              if (province != null) {
                final provinceId = province['id'].toString();

                final districts =
                await AddressService.getDistricts(
                  context,
                  provinceId,
                );

                if (!mounted) return;

                setState(() {
                  _districts = districts;
                  _wards = [];
                  _selectedDistrict = null;
                  _selectedWard = null;
                });
              }
            },
          ),
          LocationDropdown(
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
              final district = _districts
                  .cast<Map<String, dynamic>?>()
                  .firstWhere(
                    (d) => d?['name'] == name,
                orElse: () => null,
              );
              if (district != null) {
                final districtId = district['id'].toString();

                final wards = await AddressService.getWards(
                  context,
                  districtId,
                );

                if (!mounted) return;

                setState(() {
                  _wards = wards;
                  _selectedWard = null;
                });
              }
            },
          ),
          LocationDropdown(
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
          AddressTextField(
            controller: _detailController,
            label: 'Địa chỉ chi tiết',
            icon: Icons.home_outlined,
          ),
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
}