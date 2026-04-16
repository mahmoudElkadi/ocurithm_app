import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/pagination.dart';
import 'package:ocurithm/modules/PurchaseOrder/presentation/manager/get_purchase_orders_cubit/get_purchase_orders_cubit.dart';
import './purchase_order_card.dart';

class PurchaseOrderListView extends StatelessWidget {
  const PurchaseOrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetPurchaseOrdersCubit, GetPurchaseOrdersState>(
      builder: (context, state) {
        if (state.status == GetPurchaseOrdersStatus.loading) {
          return _buildLoadingList();
        } else if (state.purchaseOrders == null || state.purchaseOrders!.purchaseOrders.isEmpty) {
          return _buildEmptyState(context);
        } else {
          return _buildPurchaseOrderList(context, state);
        }
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const PurchaseOrderCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 5,
    );
  }

  Widget _buildPurchaseOrderList(BuildContext context, GetPurchaseOrdersState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          PurchaseOrderCard(
            purchaseOrder: state.purchaseOrders!.purchaseOrders[index],
            isLoading: false,
          ),
          if (index == state.purchaseOrders!.purchaseOrders.length - 1 &&
              state.purchaseOrders?.totalPages != null &&
              state.purchaseOrders!.totalPages! > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CustomPagination(
                currentPage: state.page,
                totalPages: state.purchaseOrders!.totalPages!.toInt(),
                onPageChanged: (int newPage) {
                  context
                      .read<GetPurchaseOrdersCubit>()
                      .add(SetPOPageEvent(newPage));
                },
              ),
            ),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: state.purchaseOrders!.purchaseOrders.length,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const HeightSpacer(size: 50),
          Icon(
            Icons.receipt_long_outlined,
            size: 70,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Purchase Orders found',
            style:
                theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
