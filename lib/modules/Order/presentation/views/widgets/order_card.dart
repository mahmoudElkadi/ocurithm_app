import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/modules/Order/data/models/order_model.dart';

import '../../manager/get_orders_cubit/get_orders_bloc.dart';
import './order_details_view.dart';

class OrderCard extends StatelessWidget {
  final Order? order;
  final bool isLoading;

  const OrderCard({super.key, this.order, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildShimmer(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: () async {
        if (order != null) {
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => OrderDetailsView(order: order!),
          );
          if (result == true) {
            context.read<GetOrdersBloc>().add(GetAllOrdersEvent());
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order?.orderNumber ?? "N/A",
                  style: appStyle(
                    context,
                    16,
                    primaryColor,
                    FontWeight.bold,
                  ),
                ),
                _buildStatusBadge(context, order?.status),
              ],
            ),
            const HeightSpacer(size: 8),
            Text(
              DateFormat('MMM dd, yyyy - hh:mm a')
                  .format(order?.createdAt ?? DateTime.now()),
              style: appStyle(
                context,
                12,
                Colors.grey,
                FontWeight.w500,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow(context, Icons.person_outline, "Doctor",
                order?.doctor?.name ?? "Unknown"),
            const HeightSpacer(size: 8),
            _buildInfoRow(context, Icons.business_outlined, "Branch",
                order?.branch?.name ?? "Unknown"),
            const HeightSpacer(size: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${order?.items.length ?? 0} Items",
                  style: appStyle(
                    context,
                    14,
                    isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    FontWeight.w600,
                  ),
                ),
                Text(
                  "Total: \$${order?.totalPrice?.toStringAsFixed(2) ?? "0.00"}",
                  style: appStyle(
                    context,
                    16,
                    isDark ? Colors.white : Colors.black,
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: appStyle(context, 14, Colors.grey, FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: appStyle(
              context,
              14,
              Theme.of(context).textTheme.bodyLarge!.color!,
              FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, OrderStatus? status) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.completed:
        color = Colors.green;
        text = "Completed";
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        text = "Cancelled";
        break;
      default:
        color = Colors.grey;
        text = "Unknown";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: appStyle(context, 12, color, FontWeight.bold),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    // Placeholder for loading state
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
