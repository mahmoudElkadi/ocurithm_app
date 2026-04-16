import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/modules/PurchaseOrder/presentation/manager/purchase_order_actions_cubit/purchase_order_actions_cubit.dart';
import 'package:intl/intl.dart';

class PurchaseOrderDetailsView extends StatefulWidget {
  final String poId;

  const PurchaseOrderDetailsView({super.key, required this.poId});

  @override
  State<PurchaseOrderDetailsView> createState() => _PurchaseOrderDetailsViewState();
}

class _PurchaseOrderDetailsViewState extends State<PurchaseOrderDetailsView> {
  @override
  void initState() {
    super.initState();
    context.read<PurchaseOrderActionsCubit>().add(GetPODetailsEvent(widget.poId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: BlocBuilder<PurchaseOrderActionsCubit, PurchaseOrderActionsState>(
        builder: (context, state) {
          if (state.isLoading && state.orderDetails == null) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.isError) {
            return SizedBox(
              height: 200,
              child: Center(
                  child: Text(state.errorMessage ?? "Error loading details")),
            );
          }
          final details = state.orderDetails;
          if (details == null) return const SizedBox();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "PO Details",
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
              _buildHeaderInfo(context, details),
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
                  itemCount: details.items!.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = details.items![index];
                    return _buildItemRow(context, item);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, dynamic details) {
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
          _buildInfoRow("PO Number", details.poNumber ?? ""),
          _buildInfoRow("Supplier", details.supplier?.name ?? ""),
          _buildInfoRow("Date", details.createdAt != null ? DateFormat('MMM dd, yyyy HH:mm').format(details.createdAt!) : ""),
          _buildInfoRow("Clinic", details.clinic?.name ?? ""),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, dynamic item) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.product?.name ?? "Unknown Product",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Text(
                "${item.purchasePrice}\$",
                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const HeightSpacer(size: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat("Qty", (item.quantity ?? 0).toString()),
              _buildStat("Received", item.receivedQuantity.toString()),
              _buildStat("Sold", item.soldQuantity.toString()),
              _buildStat("Remain", item.remainingQuantity.toString(), color: theme.primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
