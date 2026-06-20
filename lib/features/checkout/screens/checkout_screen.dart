import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_session.dart';
import '../../payment/screens/payOS_webview_screen.dart';

import '../models/address_model.dart';
import '../services/checkout_service.dart';

import '../widgets/address_card.dart';
import '../widgets/checkout_product_card.dart';
import '../widgets/checkout_summary.dart';
import '../widgets/checkout_bottom_bar.dart';
import '../widgets/voucher_dropdown.dart';
import '../widgets/new_address_form.dart';

import '../../voucher/models/voucher_model.dart';


class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState
    extends State<CheckoutScreen> {
  late CheckoutService _service;

  final _receiverController =
  TextEditingController();

  final _phoneController =
  TextEditingController();

  final _detailController =
  TextEditingController();

  List<AddressModel> _addresses = [];
  List<VoucherModel> _vouchers = [];

  List<String> _cartItemIds = [];

  Map<String, dynamic>? _cart;

  String? _selectedAddressId;
  String? _selectedVoucherCode;

  bool _loading = true;
  bool _showNewAddressForm = false;
  bool _calculatingShipping = false;

  double _subtotal = 0;
  double _shippingFee = 0;
  double _discount = 0;

  List<dynamic> _provinces = [];
  List<dynamic> _districts = [];
  List<dynamic> _wards = [];

  dynamic _selectedProvince;
  dynamic _selectedDistrict;
  dynamic _selectedWard;

  @override
  void initState() {
    super.initState();
    _service = CheckoutService(context);

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      final addresses =
      await _service.fetchAddresses();

      final vouchers =
      await _service.fetchVouchers();

      setState(() {
        _addresses = addresses;
        _vouchers = vouchers;

        if (addresses.isNotEmpty) {
          _selectedAddressId = addresses
              .firstWhere(
                (e) => e.isDefault,
            orElse: () => addresses.first,
          )
              .id;
        }

        _showNewAddressForm =
            addresses.isEmpty;
      });

      if (_selectedAddressId != null) {
         _calculateShippingFee(
          _selectedAddressId!,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _calculateShippingFee(
      String addressId,
      ) async {
    setState(() {
      _calculatingShipping = true;

      // reset giá cũ để tránh nhảy số
      _shippingFee = 0;
      _discount = 0;
    });

    try {
      final fee =
      await _service.calculateShippingFee(
        addressId,
      );

      setState(() {
        _shippingFee = fee;
      });

      // tính lại voucher nếu user đã chọn
      if (_selectedVoucherCode != null &&
          _selectedVoucherCode!.isNotEmpty) {
        _onVoucherChanged(
          _selectedVoucherCode,
        );
      }
    } catch (e) {
      debugPrint(
        'Calculate shipping error: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _calculatingShipping = false;
        });
      }
    }
  }

  Future<void> _checkout() async {
    final user =
        UserSession.currentUser;

    if (user == null ||
        _selectedAddressId == null) {
      return;
    }

    final result =
    await _service.checkout(
      userId: user.id,
      addressId: _selectedAddressId!,
      voucherCode:
      _selectedVoucherCode,
      cartItemIds: _cartItemIds,
    );

    if (result == null ||
        !mounted) {
      return;
    }

    final payment =
    result['payment']
    as Map<String, dynamic>?;

    final checkoutUrl =
    payment?['checkoutUrl']
        ?.toString();

    if (checkoutUrl != null &&
        checkoutUrl.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PayOsWebViewScreen(
                checkoutUrl: checkoutUrl,
                orderCode:
                payment?['orderCode'] ??
                    0,
              ),
        ),
      );

      return;
    }

    Navigator.pushReplacementNamed(
      context,
      '/orders',
    );
  }

  void _onVoucherChanged(
      String? code) {
    setState(() {
      _selectedVoucherCode = code;

      if (code == null ||
          code.isEmpty) {
        _discount = 0;
        return;
      }

      final voucher =
      _vouchers.firstWhere(
            (e) => e.code == code,
      );

      if (voucher.discountType
          .toUpperCase() ==
          'PERCENT') {
        _discount =
            (_subtotal +
                _shippingFee) *
                voucher.discountValue /
                100;
      } else {
        _discount =
            voucher.discountValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cart == null) {
      final args =
          ModalRoute.of(context)
              ?.settings
              .arguments;

      if (args is Map<String, dynamic>) {
        _cart = args;

        _subtotal =
            (_cart!['totalPrice']
            as num?)
                ?.toDouble() ??
                0;

        _cartItemIds =
            (_cart!['items'] as List)
                .map<String>(
                  (e) =>
                  (e['cartItemId'] ??
                      e['id'])
                      .toString(),
            )
                .toList();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đặt hàng',
        ),
        backgroundColor:
        AppColors.wine,
      ),
      body: _loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : ListView(
        padding:
        const EdgeInsets.all(
          16,
        ),
        children: [
          const Text(
            'Sản phẩm',
          ),

          const SizedBox(
            height: 12,
          ),

          ...(_cart!['items']
          as List)
              .map(
                (item) =>
                CheckoutProductCard(
                  item: item,
                ),
          ),

          const SizedBox(
            height: 20,
          ),

          const Text(
            'Địa chỉ giao hàng',
          ),

          const SizedBox(
            height: 12,
          ),

          ..._addresses.map(
                (address) =>
                AddressCard(
                  address: address,
                  selected:
                  address.id ==
                      _selectedAddressId,
                  onTap: () async {
                    if (_selectedAddressId ==
                        address.id) {
                      return;
                    }

                    setState(() {
                      _selectedAddressId =
                          address.id;

                      _shippingFee = 0;
                      _discount = 0;
                    });

                    await _calculateShippingFee(
                      address.id,
                    );
                  },
                ),
          ),
          FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                '/address-form',
              );

              await _initializeData();
            },
            icon: const Icon(Icons.add),
            label: const Text('Thêm địa chỉ'),
          ),
          if (_showNewAddressForm)
            NewAddressForm(
              receiverController:
              _receiverController,
              phoneController:
              _phoneController,
              detailController:
              _detailController,
              provinces:
              _provinces,
              districts:
              _districts,
              wards: _wards,
              selectedProvince:
              _selectedProvince,
              selectedDistrict:
              _selectedDistrict,
              selectedWard:
              _selectedWard,
              onProvinceChanged:
                  (_) {},
              onDistrictChanged:
                  (_) {},
              onWardChanged:
                  (_) {},
            ),

          const SizedBox(
            height: 16,
          ),

          VoucherDropdown(
            vouchers: _vouchers,
            selectedCode:
            _selectedVoucherCode,
            onChanged:
            _onVoucherChanged,
          ),

          const SizedBox(
            height: 16,
          ),

          CheckoutSummary(
            subtotal: _subtotal,
            shippingFee:
            _shippingFee,
            discount:
            _discount,
            isLoadingShipping:
            _calculatingShipping,
          ),

          const SizedBox(
            height: 16,
          ),

          CheckoutBottomBar(
            onCheckout:
            _checkout,
          ),
        ],
      ),
    );
  }
}