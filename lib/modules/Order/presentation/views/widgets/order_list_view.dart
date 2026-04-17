import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/pagination.dart';
import 'package:ocurithm/modules/Order/presentation/manager/get_orders_cubit/get_orders_bloc.dart';
import './order_card.dart';

class OrderListView extends StatelessWidget {
  const OrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetOrdersBloc, GetOrdersState>(
      builder: (context, state) {
        if (state.status == GetOrdersStatus.loading) {
          return _buildLoadingList();
        } else if (state.orders == null || state.orders!.orders.isEmpty) {
          return _buildEmptyState(context);
        } else {
          return _buildOrderList(context, state);
        }
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const OrderCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 3,
    );
  }

  Widget _buildOrderList(BuildContext context, GetOrdersState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          OrderCard(
            order: state.orders!.orders[index],
            isLoading: false,
          ),
          if (index == state.orders!.orders.length - 1 &&
              state.orders?.totalPages != null &&
              state.orders!.totalPages! > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CustomPagination(
                currentPage: state.page,
                totalPages: state.orders!.totalPages!.toInt(),
                onPageChanged: (int newPage) {
                  context
                      .read<GetOrdersBloc>()
                      .add(SetOrderPageEvent(newPage));
                },
              ),
            ),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: state.orders!.orders.length,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const HeightSpacer(size: 30),
          Icon(
            Icons.shopping_bag_outlined,
            size: 70,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Orders found',
            style:
                theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
