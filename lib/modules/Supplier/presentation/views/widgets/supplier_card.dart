import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/supplier_model.dart';
import '../../manager/get_suppliers_cubit/get_suppliers_cubit.dart';
import '../../manager/supplier_actions_cubit/supplier_actions_cubit.dart';
import './supplier_form_bottom_sheet.dart';

class SupplierCard extends StatelessWidget {
  final bool isLoading;
  final Supplier? supplier;

  const SupplierCard({
    super.key,
    required this.isLoading,
    this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: isLoading || supplier == null
            ? null
            : () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(
                          value: context.read<SupplierActionsCubit>()),
                      BlocProvider.value(
                          value: context.read<GetSuppliersCubit>()),
                    ],
                    child: SupplierFormBottomSheet(supplier: supplier),
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
                        shape: BoxShape.circle,
                        color: Colors.white),
                  ),
                )
              else
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primaryColor.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.business,
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
                        supplier?.name ?? "No Name",
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
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: theme.textTheme.bodySmall?.color),
                          const WidthSpacer(size: 5),
                          Text(
                            supplier?.phoneNumber ?? "No Phone",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (!isLoading) ...[
                _buildStatusBadge(context, supplier?.isActive ?? true),
                const WidthSpacer(size: 10),
                BlocBuilder<SupplierActionsCubit, SupplierActionsState>(
                  builder: (context, state) {
                    if (state.isLoading && state.actingId == supplier?.id) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    return IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(context),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isActive) {
    final color = isActive ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Delete Supplier"),
        content: const Text("Are you sure you want to delete this supplier?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              context
                  .read<SupplierActionsCubit>()
                  .add(DeleteSupplierEvent(supplier!.id!));
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
