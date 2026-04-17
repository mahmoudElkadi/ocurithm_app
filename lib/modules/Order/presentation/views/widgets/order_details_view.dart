import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/modules/Order/data/models/order_model.dart';
import 'package:ocurithm/modules/Order/presentation/manager/order_actions_cubit/order_actions_bloc.dart';
import 'package:ocurithm/modules/Order/presentation/views/create_order/create_order_page.dart';

import '../../../../../core/utils/services_locator.dart';
import '../../../data/repos/order_repo.dart';

class OrderDetailsView extends StatefulWidget {
  final Order order;

  const OrderDetailsView({super.key, required this.order});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  Order? _liveOrder;

  @override
  void initState() {
    super.initState();
    _liveOrder = widget.order;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final order = await sl<OrderRepo>().getOrderById(widget.order.id!);
      if (mounted) {
        setState(() {
          _liveOrder = order;
        });
      }
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final order = _liveOrder ?? widget.order;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order Details",
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const HeightSpacer(size: 20),
          _buildHeaderInfo(context, order),
          const HeightSpacer(size: 20),
          Text(
            "Items",
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const HeightSpacer(size: 10),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: order.items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return _buildItemRow(context, item);
              },
            ),
          ),
          const HeightSpacer(size: 30),
          if (order.status == OrderStatus.completed)
            _buildActions(context, order),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, Order order) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildInfoRow("Order Number", order.orderNumber ?? ""),
          _buildInfoRow("Status", order.status?.name.toUpperCase() ?? ""),
          _buildInfoRow("Doctor", order.doctor?.name ?? "Unknown"),
          _buildInfoRow("Branch", order.branch?.name ?? "Unknown"),
          _buildInfoRow("Date",
              DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt!)),
          _buildInfoRow(
              "Total Price", "\$${order.totalPrice?.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, OrderItem item) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? "Unknown Product",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "SKU: ${item.productSku}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${item.quantity} x \$${item.productPrice}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                "\$${((item.quantity ?? 0) * (item.productPrice ?? 0)).toStringAsFixed(2)}",
                style: TextStyle(
                    color: theme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, Order order) {
    return BlocProvider.value(
      value: sl<OrderActionsBloc>(),
      child: BlocConsumer<OrderActionsBloc, OrderActionsState>(
        listener: (context, state) {
          if (state.status == OrderActionsStatus.success) {
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateOrderPage(orderToEdit: order),
                      ),
                    );
                    if (result == true) {
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Edit Order",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const HeightSpacer(size: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.status == OrderActionsStatus.loading
                      ? null
                      : () => _confirmCancel(context, order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: state.status == OrderActionsStatus.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Cancel Order",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmCancel(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text(
            "Are you sure you want to cancel this order? This action cannot be undone and stock will be restored."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OrderActionsBloc>().add(CancelOrderEvent(order.id!));
            },
            child:
                const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
