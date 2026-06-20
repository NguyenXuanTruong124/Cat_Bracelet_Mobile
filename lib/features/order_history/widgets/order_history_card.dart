import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/price_formatter.dart';
import '../models/order_history_model.dart';
import 'order_history_status_chip.dart';

class OrderHistoryCard
    extends StatelessWidget {
  final OrderHistoryModel order;
  final VoidCallback onTap;

  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(16),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding:
          const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color: AppColors
                  .outlineVariant
                  .withValues(
                alpha: 0.2,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration:
                BoxDecoration(
                  color: AppColors
                      .surfaceContainer,
                  borderRadius:
                  BorderRadius
                      .circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color:
                  AppColors.primary,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      'Đơn #CB-${order.shortId}',
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      DateFormatter
                          .ddMMyyyy(
                        order.createdAt.toString(),
                      ),
                      style:
                      const TextStyle(
                        fontSize: 13,
                        color: AppColors
                            .onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    OrderHistoryStatusChip(
                      status:
                      order.status,
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .end,
                children: [
                  Text(
                    PriceFormatter
                        .format(
                      order.totalAmount,
                    ),
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight
                          .bold,
                      color: AppColors
                          .primary,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Icon(
                    Icons
                        .arrow_forward_ios,
                    size: 14,
                    color: AppColors
                        .secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}