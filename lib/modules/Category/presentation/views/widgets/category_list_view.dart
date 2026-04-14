import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/pagination.dart';
import '../../manager/get_categories_cubit/get_categories_cubit.dart';
import './category_card.dart';

class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetCategoriesCubit, GetCategoriesState>(
      builder: (context, state) {
        if (state.status == GetCategoriesStatus.loading) {
          return _buildLoadingList();
        } else if (state.categories == null || state.categories!.categories.isEmpty) {
          return _buildEmptyState(context);
        } else {
          return _buildCategoryList(context, state);
        }
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const CategoryCard(isLoading: true),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: 3,
    );
  }

  Widget _buildCategoryList(BuildContext context, GetCategoriesState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Column(
        children: [
          CategoryCard(
            category: state.categories!.categories[index],
            isLoading: false,
          ),
          if (index == state.categories!.categories.length - 1 &&
              state.categories?.totalPages != null &&
              state.categories!.totalPages! > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CustomPagination(
                currentPage: state.page,
                totalPages: state.categories!.totalPages!.toInt(),
                onPageChanged: (int newPage) {
                  context.read<GetCategoriesCubit>().add(SetPageEvent(newPage));
                },
              ),
            ),
        ],
      ),
      separatorBuilder: (context, index) => const HeightSpacer(size: 20),
      itemCount: state.categories!.categories.length,
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
            Icons.category_outlined,
            size: 70,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Categories found',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
