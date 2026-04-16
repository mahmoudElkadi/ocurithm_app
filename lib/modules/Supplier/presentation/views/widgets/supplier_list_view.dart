import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/pagination.dart';
import 'package:ocurithm/modules/Supplier/presentation/manager/get_suppliers_cubit/get_suppliers_cubit.dart';
import './supplier_card.dart';

class SupplierListView extends StatelessWidget {
  const SupplierListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSuppliersCubit, GetSuppliersState>(
      builder: (context, state) {
        if (state.status == GetSuppliersStatus.loading) {
          return _buildLoadingList();
        } else if (state.suppliers == null || state.suppliers!.suppliers.isEmpty) {
          return _buildEmptyState(context);
        } else {
          return _buildSupplierList(context, state);
        }
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const SupplierCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 5,
    );
  }

  Widget _buildSupplierList(BuildContext context, GetSuppliersState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          SupplierCard(
            supplier: state.suppliers!.suppliers[index],
            isLoading: false,
          ),
          if (index == state.suppliers!.suppliers.length - 1 &&
              state.suppliers?.totalPages != null &&
              state.suppliers!.totalPages! > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CustomPagination(
                currentPage: state.page,
                totalPages: state.suppliers!.totalPages!.toInt(),
                onPageChanged: (int newPage) {
                  context
                      .read<GetSuppliersCubit>()
                      .add(SetSupplierPageEvent(newPage));
                },
              ),
            ),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: state.suppliers!.suppliers.length,
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
            Icons.local_shipping_outlined,
            size: 70,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Suppliers found',
            style:
                theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
