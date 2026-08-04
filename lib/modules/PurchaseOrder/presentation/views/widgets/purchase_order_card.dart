import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';
import 'package:ocurithm/core/utils/capability_services.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../../../data/models/purchase_order_model.dart';
import '../../manager/purchase_order_actions_cubit/purchase_order_actions_cubit.dart';
import './purchase_order_details_view.dart';

class PurchaseOrderCard extends StatelessWidget {
  final bool isLoading;
  final PurchaseOrderHeader? purchaseOrder;

  const PurchaseOrderCard({
    super.key,
    required this.isLoading,
    this.purchaseOrder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: isLoading || purchaseOrder == null
            ? null
            : () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(
                          value: context.read<PurchaseOrderActionsCubit>()),
                    ],
                    child: PurchaseOrderDetailsView(poId: purchaseOrder!.id!),
                  ),
                );
              },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 15.w),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
            border: isDark
                ? Border.all(color: Colors.white.withValues(alpha: 0.1))
                : null,
          ),
          child: Row(
            children: [
              if (isLoading)
                _buildShimmer(
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white),
                  ),
                )
              else
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: theme.primaryColor.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.receipt,
                      color: theme.primaryColor,
                      size: 26,
                    ),
                  ),
                ),
              const WidthSpacer(size: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      _buildShimmer(
                        Container(
                          width: 150,
                          height: 20,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                        ),
                      )
                    else
                      Text(
                        purchaseOrder?.poNumber ?? "No PO#",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    const HeightSpacer(size: 5),
                    if (isLoading)
                      _buildShimmer(
                        Container(
                          width: 100,
                          height: 15,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            purchaseOrder?.supplier?.name ?? "No Supplier",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const HeightSpacer(size: 2),
                          Text(
                            purchaseOrder?.createdAt != null
                                ? DateFormat('MMM dd, yyyy')
                                    .format(purchaseOrder!.createdAt!)
                                : "",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (!isLoading)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${purchaseOrder?.totalItems ?? 0} Items",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const HeightSpacer(size: 5),
                    if (CapabilityServices.hasCapability(
                        CapabilityKeys.manageProducts))
                      BlocBuilder<PurchaseOrderActionsCubit,
                          PurchaseOrderActionsState>(
                        builder: (context, state) {
                          if (state.isLoading &&
                              state.actingId == purchaseOrder?.id) {
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          return IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () => _showDeleteConfirmation(context),
                            visualDensity: VisualDensity.compact,
                          );
                        },
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Delete Purchase Order"),
        content: const Text(
            "Are you sure you want to delete this PO? This will reverse stock and delete inventory units."),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              context
                  .read<PurchaseOrderActionsCubit>()
                  .add(DeletePOEvent(purchaseOrder!.id!));
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }
}
