import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/price_formatter.dart';
import 'package:cat_bracelet_mobile/features/product/models/product.dart';

/// Thẻ hiển thị một sản phẩm trong lưới sản phẩm của màn hình bộ sưu tập.
class ProductGridCard extends StatelessWidget {
  final Product product;
  final String imageUrl;
  final VoidCallback onTap;

  const ProductGridCard({
    super.key,
    required this.product,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 6, child: _ProductImage(imageUrl: imageUrl)),
            Expanded(
              flex: 5,
              child: _ProductInfo(product: product, onViewDetails: onTap),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.softRose,
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 40.sp,
                );
              },
            )
          : Icon(Icons.image_not_supported, color: Colors.grey, size: 40.sp),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final Product product;
  final VoidCallback onViewDetails;

  const _ProductInfo({required this.product, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.productName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF333333),
              height: 1.3,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            PriceFormatter.format(product.basePrice),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.wine,
            ),
          ),
          const Spacer(),
          _ViewDetailsButton(onPressed: onViewDetails),
        ],
      ),
    );
  }
}

class _ViewDetailsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ViewDetailsButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 30.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.wine,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.visibility, size: 14.sp),
              SizedBox(width: 4.w),
              Text(
                'Chi tiết',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
