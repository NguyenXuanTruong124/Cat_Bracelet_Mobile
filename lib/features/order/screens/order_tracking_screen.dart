import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../core/config/api_config.dart';
import '../../../core/services/api_helpers.dart';
import '../../../core/theme/app_colors.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Map<String, dynamic>? _order;
  bool _isLoading = true;

  static const _steps = [
    _TrackingStep(
      title: 'Đã đặt hàng',
      subtitle: 'Hệ thống đã nhận đơn hàng',
      icon: Icons.check,
    ),
    _TrackingStep(
      title: 'Đang chuẩn bị hàng',
      subtitle: 'Nhân viên đang thanh tẩy & đóng gói',
      icon: Icons.check,
    ),
    _TrackingStep(
      title: 'Đã giao cho đơn vị vận chuyển',
      subtitle: 'Đơn hàng rời kho',
      icon: Icons.local_shipping,
      activeIcon: Icons.local_shipping,
    ),
    _TrackingStep(
      title: 'Đang giao đến bạn',
      subtitle: 'Dự kiến trong ngày giao',
      icon: Icons.local_shipping_outlined,
    ),
    _TrackingStep(
      title: 'Giao hàng thành công',
      subtitle: '',
      icon: Icons.check_circle_outline,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    try {
      final baseUrl = ApiConfig.getBaseUrl(context);
      final response = await http.get(
        Uri.parse('$baseUrl/orders/${widget.orderId}'),
        headers: apiHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          _order = decoded;
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _activeStepIndex(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'PENDING':
        return 0;
      case 'CONFIRMED':
      case 'PROCESSING':
        return 1;
      case 'SHIPPING':
      case 'SHIPPED':
        return 2;
      case 'OUT_FOR_DELIVERY':
        return 3;
      case 'DELIVERED':
      case 'COMPLETED':
        return 4;
      case 'CANCELLED':
        return -1;
      default:
        return 0;
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final date = DateTime.parse(raw).toLocal();
      return DateFormat("dd/MM/yyyy 'lúc' HH:mm", 'vi').format(date);
    } catch (_) {
      return raw;
    }
  }

  String _formatDateShort(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final date = DateTime.parse(raw).toLocal();
      return DateFormat("d 'Tháng' M, yyyy", 'vi').format(date);
    } catch (_) {
      return raw;
    }
  }

  String _price(dynamic value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(toDouble(value));
  }

  Map<String, dynamic>? _firstProduct(Map<String, dynamic>? order) {
    final items = decodeListPayload(order?['items']);
    if (items.isEmpty) return null;
    final item = items.first as Map<String, dynamic>;
    return readProductPayload(item);
  }

  Map<String, dynamic>? _firstItem(Map<String, dynamic>? order) {
    final items = decodeListPayload(order?['items']);
    if (items.isEmpty) return null;
    return items.first as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final status = order?['status']?.toString();
    final activeIndex = _activeStepIndex(status);
    final isCancelled = status?.toUpperCase() == 'CANCELLED';
    final address = order?['address'] as Map<String, dynamic>?;
    final product = _firstProduct(order);
    final item = _firstItem(order);
    final variant = item?['variant'] as Map<String, dynamic>?;
    final baseUrl = ApiConfig.getBaseUrl(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text(
          'THEO DÕI ĐƠN HÀNG',
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : order == null
          ? const Center(child: Text('Không tải được đơn hàng'))
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
                  children: [
                    _buildOrderHeader(order),
                    if (isCancelled) _buildCancelledBanner(),
                    if (!isCancelled) ...[
                      const SizedBox(height: 32),
                      ...List.generate(_steps.length, (index) {
                        return _buildStep(
                          step: _steps[index],
                          index: index,
                          activeIndex: activeIndex,
                          createdAt: order['createdAt']?.toString(),
                          isLast: index == _steps.length - 1,
                        );
                      }),
                    ],
                    const SizedBox(height: 24),
                    if (item != null) _buildProductCard(product, item, variant, baseUrl),
                    const SizedBox(height: 24),
                    if (address != null) _buildAddressSection(address),
                  ],
                ),
                _buildBottomActions(),
              ],
            ),
    );
  }

  Widget _buildOrderHeader(Map<String, dynamic> order) {
    final shortId = order['id']?.toString().substring(0, 8).toUpperCase() ?? '';
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.secondaryContainer),
          ),
          child: Text(
            'Mã đơn hàng: #CB-$shortId',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Ngày đặt: ${_formatDateShort(order['createdAt']?.toString())}',
          style: const TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Trạng thái: ${_statusLabel(order['status']?.toString())}',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCancelledBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBA1A1A).withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.cancel_outlined, color: Color(0xFFBA1A1A)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Đơn hàng đã bị hủy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF93000A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required _TrackingStep step,
    required int index,
    required int activeIndex,
    required String? createdAt,
    required bool isLast,
  }) {
    final isCompleted = index < activeIndex;
    final isActive = index == activeIndex;
    final isPending = index > activeIndex;

    Color lineColor = AppColors.outlineVariant;
    if (isCompleted) lineColor = AppColors.primaryContainer;
    if (isActive) lineColor = AppColors.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isPending
                        ? AppColors.outlineVariant.withValues(alpha: 0.3)
                        : AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? AppColors.primaryContainer.withValues(alpha: 0.3)
                          : AppColors.background,
                      width: 4,
                    ),
                  ),
                  child: isPending
                      ? null
                      : Icon(
                          isActive ? step.activeIcon : step.icon,
                          size: 14,
                          color: Colors.white,
                        ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isCompleted
                          ? AppColors.primaryContainer
                          : lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? AppColors.primary
                          : isPending
                          ? AppColors.onSurfaceVariant.withValues(alpha: 0.6)
                          : AppColors.onSurface,
                    ),
                  ),
                  if (step.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      index == 0 && createdAt != null
                          ? '${_formatDate(createdAt)} | ${step.subtitle}'
                          : step.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: isPending ? FontStyle.italic : FontStyle.normal,
                        color: isActive
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant.withValues(
                                alpha: isPending ? 0.6 : 1,
                              ),
                      ),
                    ),
                  ],
                  if (isActive && index == 2) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.location_on, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Đang trung chuyển tới địa chỉ nhận hàng',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    Map<String, dynamic>? product,
    Map<String, dynamic> item,
    Map<String, dynamic>? variant,
    String baseUrl,
  ) {
    final name = product?['productName']?.toString() ?? 'Sản phẩm';
    final thumbnail = buildImageUrl(baseUrl, readThumbnailPath(product));
    final size = variant?['size']?.toString() ?? '';
    final qty = item['quantity'] ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.outlineVariant),
        const SizedBox(height: 12),
        const Text(
          'SẢN PHẨM ĐANG VẬN CHUYỂN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.05),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 96,
                  height: 96,
                  color: AppColors.surfaceContainer,
                  child: thumbnail.isNotEmpty
                      ? Image.network(
                          thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, color: AppColors.outlineVariant),
                        )
                      : const Icon(Icons.image, color: AppColors.outlineVariant),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Số lượng: ${qty.toString().padLeft(2, '0')}${size.isNotEmpty ? ' • Size: $size' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _price(item['totalPrice']),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection(Map<String, dynamic> address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.outlineVariant),
        const SizedBox(height: 12),
        const Text(
          'THÔNG TIN NHẬN HÀNG',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.person_outline, color: AppColors.gold, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address['receiverName']?.toString() ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          address['phone']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.home_outlined, color: AppColors.gold, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${address['detailAddress'] ?? ''}, ${address['ward'] ?? ''}, ${address['district'] ?? ''}, ${address['province'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.background,
              AppColors.background.withValues(alpha: 0.9),
              AppColors.background.withValues(alpha: 0),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Liên hệ hỗ trợ: support@catbracelet.com')),
                  );
                },
                icon: const Icon(Icons.support_agent),
                label: const Text(
                  'LIÊN HỆ HỖ TRỢ',
                  style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'PENDING':
        return 'Chờ xác nhận';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'SHIPPING':
      case 'SHIPPED':
        return 'Đang vận chuyển';
      case 'OUT_FOR_DELIVERY':
        return 'Đang giao hàng';
      case 'DELIVERED':
      case 'COMPLETED':
        return 'Đã giao hàng';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status ?? '';
    }
  }
}

class _TrackingStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final IconData activeIcon;

  const _TrackingStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    IconData? activeIcon,
  }) : activeIcon = activeIcon ?? icon;
}
