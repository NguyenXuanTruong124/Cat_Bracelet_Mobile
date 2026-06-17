import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_session.dart';
import '../../../core/services/api_helpers.dart';
import 'package:cat_bracelet_mobile/features/payment/screen/payOS_webview_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color _wine = AppColors.wine;

  final _receiverController = TextEditingController();
  final _phoneController = TextEditingController();
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _wardController = TextEditingController();
  final _detailController = TextEditingController();
  List<String> _cartItemIds = [];
  List<Map<String, dynamic>> _addresses = [];
  Map<String, dynamic>? _cart;

  double _subtotal = 0;
  double _shippingFee = 0;
  double _discount = 0;

  List<dynamic> _provinces = [];
  List<dynamic> _districts = [];
  List<dynamic> _wards = [];

  dynamic _selectedProvince;
  dynamic _selectedDistrict;
  dynamic _selectedWard;

  String? _selectedAddressId;
  bool _isLoading = true;
  bool _showNewAddressForm = false;
  bool _isCalculatingShipping = false;

  List<dynamic> _vouchers = [];
  String? _selectedVoucherCode;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
    _loadProvinces();
    _loadVouchers();
  }

  @override
  void dispose() {
    _receiverController.dispose();
    _phoneController.dispose();
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
        if (_selectedAddressId != null) {
          await _calculateShippingFee(_selectedAddressId!);
        }
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

  Future<void> _loadProvinces() async {
    try {
      final response = await http.get(
        Uri.parse('https://provinces.open-api.vn/api/p/'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _provinces = jsonDecode(response.body);
        });
      }
    } catch (_) {}
  }

  Future<void> _loadDistricts(int provinceCode) async {
    try {
      final response = await http.get(
        Uri.parse('https://provinces.open-api.vn/api/p/$provinceCode?depth=2'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _districts = data['districts'] ?? [];
          _wards = [];
          _selectedDistrict = null;
          _selectedWard = null;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadWards(int districtCode) async {
    try {
      final response = await http.get(
        Uri.parse('https://provinces.open-api.vn/api/d/$districtCode?depth=2'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _wards = data['wards'] ?? [];
          _selectedWard = null;
        });
      }
    } catch (_) {}
  }

  Future<String?> _createAddressIfNeeded() async {
    final user = UserSession.currentUser;
    if (user == null) {
      return null;
    }
    if (!_showNewAddressForm) {
      _receiverController.clear();
      _phoneController.clear();
      _detailController.clear();

      _selectedProvince = null;
      _selectedDistrict = null;
      _selectedWard = null;

      _districts.clear();
      _wards.clear();
      return _selectedAddressId;
    }

    final receiver = _receiverController.text.trim();
    final phone = _phoneController.text.trim();
    final province = _selectedProvince?['name'] ?? '';
    final district = _selectedDistrict?['name'] ?? '';
    final ward = _selectedWard?['name'] ?? '';
    final detail = _detailController.text.trim();

    if (receiver.isEmpty ||
        phone.isEmpty ||
        detail.isEmpty ||
        _selectedProvince == null ||
        _selectedDistrict == null ||
        _selectedWard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập đầy đủ địa chỉ giao hàng')),
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
        final newAddressId = decoded['id']?.toString();

        if (newAddressId != null) {
          await _calculateShippingFee(newAddressId);
        }

        return newAddressId;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo địa chỉ lỗi: ${response.statusCode}')),
      );
    }
    return null;
  }

  Future<void> _checkout() async {
    final user = UserSession.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final addressId = await _createAddressIfNeeded();
      if (addressId == null) {
        return;
      }

      final body = {
        'userId': user.id,
        'addressId': addressId,
        'voucherCode': _selectedVoucherCode,
        'cartItemIds': _cartItemIds,
      };

      debugPrint('CHECKOUT BODY: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse('$baseUrl/orders/checkout'),
        headers: apiHeaders(json: true),
        body: jsonEncode(body),
      );

      debugPrint('CHECKOUT RESPONSE: ${response.body}');

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);

        final payment = result['payment'] as Map<String, dynamic>?;

        final checkoutUrl = payment?['checkoutUrl']?.toString();

        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PayOsWebViewScreen(
                checkoutUrl: checkoutUrl,
                orderCode: payment?['orderCode'] ?? 0,
              ),
            ),
          );

          return;
        }
        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/orders');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đặt hàng: ${response.statusCode}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cart == null) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is Map<String, dynamic>) {
        _cart = args;

        _subtotal = (_cart!['totalPrice'] as num?)?.toDouble() ?? 0;

        _cartItemIds = (_cart!['items'] as List)
            .map<String>((e) => (e['cartItemId'] ?? e['id']).toString())
            .toList();
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt hàng'),
        backgroundColor: _wine,
        foregroundColor: Colors.white,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _wine))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Sản phẩm',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                if (_cart != null)
                  ...(_cart!['items'] as List).map((item) {
                    final product = item['product'];
                    final variant = item['variantDetails'];

                    return Card(
                      child: ListTile(
                        title: Text(product['productName']),
                        subtitle: Text(
                          '${variant['color']} - ${variant['size']}\n'
                          '${item['quantity']} x ${_money((item['unitPrice'] as num).toDouble())}',
                        ),
                        trailing: Text(
                          _money((item['subTotal'] as num).toDouble()),
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 20),

                const Text(
                  'Địa chỉ giao hàng',
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
                    label: const Text('Thêm địa chỉ mới'),
                  ),
                ],

                if (_showNewAddressForm) ...[
                  _newAddressForm(),

                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: () async {
                      final newAddressId = await _createAddressIfNeeded();

                      if (newAddressId == null) {
                        return;
                      }

                      await _fetchAddresses();

                      setState(() {
                        _selectedAddressId = newAddressId;

                        _showNewAddressForm = false;
                      });
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Lưu địa chỉ'),
                  ),
                ],

                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedVoucherCode,
                  decoration: const InputDecoration(
                    labelText: 'Chọn voucher',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Không sử dụng voucher'),
                    ),

                    ..._vouchers.map<DropdownMenuItem<String>>((voucher) {
                      return DropdownMenuItem<String>(
                        value: voucher['code']?.toString(),
                        child: Text(
                          '${voucher['code']} - Giảm ${voucher['discountValue']}',
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedVoucherCode = value;

                      // Không dùng voucher
                      if (value == null || value.isEmpty) {
                        _discount = 0;
                        return;
                      }

                      final voucher = _vouchers
                          .cast<Map<String, dynamic>>()
                          .firstWhere(
                            (v) => v['code'] == value,
                            orElse: () => {},
                          );

                      final discountValue =
                          double.tryParse(
                            voucher['discountValue']?.toString() ?? '0',
                          ) ??
                          0;

                      final discountType = voucher['discountType']
                          ?.toString()
                          .toUpperCase();

                      if (discountType == 'PERCENT') {
                        _discount =
                            (_subtotal + _shippingFee) * discountValue / 100;
                      } else {
                        _discount = discountValue;
                      }
                    });
                  },
                ),

                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _summaryRow('Tiền hàng', _subtotal),
                        if (_isCalculatingShipping)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Phí ship'),
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _wine,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          _summaryRow('Phí ship', _shippingFee),

                          if (_shippingFee > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Phí ship được tính theo địa chỉ giao hàng đã chọn',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                        _summaryRow('Giảm giá', -_discount),
                        const Divider(),
                        if (_isCalculatingShipping)
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tổng thanh toán',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ],
                          )
                        else
                          _summaryRow(
                            'Tổng thanh toán',
                            _subtotal + _shippingFee - _discount,
                            isBold: true,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _wine,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _checkout,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Xác nhận đặt hàng'),
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
        onTap: () async {
          setState(() {
            _selectedAddressId = id;
            _showNewAddressForm = false;
          });

          if (id != null) {
            await _calculateShippingFee(id);
          }
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

        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DropdownButtonFormField<dynamic>(
            value: _selectedProvince,
            decoration: const InputDecoration(
              labelText: 'Tinh/Thanh pho',
              border: OutlineInputBorder(),
            ),
            items: _provinces.map((province) {
              return DropdownMenuItem(
                value: province,
                child: Text(province['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProvince = value;
              });

              _loadDistricts(value['code']);
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DropdownButtonFormField<dynamic>(
            value: _selectedDistrict,
            decoration: const InputDecoration(
              labelText: 'Quan/Huyen',
              border: OutlineInputBorder(),
            ),
            items: _districts.map((district) {
              return DropdownMenuItem(
                value: district,
                child: Text(district['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDistrict = value;
              });

              _loadWards(value['code']);
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DropdownButtonFormField<dynamic>(
            value: _selectedWard,
            decoration: const InputDecoration(
              labelText: 'Phuong/Xa',
              border: OutlineInputBorder(),
            ),
            items: _wards.map((ward) {
              return DropdownMenuItem(value: ward, child: Text(ward['name']));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedWard = value;
              });
            },
          ),
        ),

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

  Widget _summaryRow(String label, double amount, {bool isBold = false}) {
    print('$label = $amount');
    print(_subtotal);
    print(_shippingFee);
    print(_discount);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _money(amount),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadVouchers() async {
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);

      final response = await http.get(
        Uri.parse('$baseUrl/vouchers'),
        headers: apiHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _vouchers = decodeListPayload(data)
              .where(
                (v) => (v['status'] ?? '').toString().toUpperCase() == 'ACTIVE',
              )
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Không thể tải danh sách voucher: $e');
    }
  }

  Future<void> _calculateShippingFee(String addressId) async {
    setState(() {
      _isCalculatingShipping = true;
    });
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);

      final response = await http.post(
        Uri.parse('$baseUrl/shipments/calculate-client'),
        headers: apiHeaders(json: true),
        body: jsonEncode({'addressId': addressId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _shippingFee = (data['total_shipping_fee'] as num?)?.toDouble() ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tính phí ship: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCalculatingShipping = false;
        });
      }
    }
  }

  String _money(double value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(value);
  }
}
