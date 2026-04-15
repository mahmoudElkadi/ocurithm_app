import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/pagination.dart';
import 'package:ocurithm/modules/Product/presentation/manager/get_products_cubit/get_products_cubit.dart';
import './product_card.dart';

class ProductListView extends StatelessWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetProductsCubit, GetProductsState>(
      builder: (context, state) {
        if (state.status == GetProductsStatus.loading) {
          return _buildLoadingList();
        } else if (state.products == null || state.products!.products.isEmpty) {
          return _buildEmptyState(context);
        } else {
          return _buildProductList(context, state);
        }
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const ProductCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 3,
    );
  }

  Widget _buildProductList(BuildContext context, GetProductsState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          ProductCard(
            product: state.products!.products[index],
            isLoading: false,
          ),
          if (index == state.products!.products.length - 1 &&
              state.products?.totalPages != null &&
              state.products!.totalPages! > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CustomPagination(
                currentPage: state.page,
                totalPages: state.products!.totalPages!.toInt(),
                onPageChanged: (int newPage) {
                  context
                      .read<GetProductsCubit>()
                      .add(SetProductPageEvent(newPage));
                },
              ),
            ),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: state.products!.products.length,
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
            Icons.inventory_2_outlined,
            size: 70,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Products found',
            style:
                theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
