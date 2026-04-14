import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/SubCategory/presentation/manager/get_sub_categories_cubit/get_sub_categories_cubit.dart';
import 'sub_category_card.dart';

class SubCategoryListView extends StatelessWidget {
  const SubCategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSubCategoriesCubit, GetSubCategoriesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return ListView.separated(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            itemCount: 5,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) => const SubCategoryCard(isLoading: true),
          );
        }

        if (state.isError) {
          return Center(child: Text(state.errorMessage ?? "Failed to load sub-categories"));
        }
        
        final subCategories = state.subCategories?.subCategories ?? [];

        if (subCategories.isEmpty && state.isSuccess) {
          return const Center(child: Text("No sub-categories found"));
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<GetSubCategoriesCubit>().add(GetAllSubCategoriesEvent());
          },
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            itemCount: subCategories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) => SubCategoryCard(
              isLoading: false,
              subCategory: subCategories[index],
            ),
          ),
        );
      },
    );
  }
}
