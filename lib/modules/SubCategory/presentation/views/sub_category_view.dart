import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/manage_capabilities.dart';
import '../manager/get_sub_categories_cubit/get_sub_categories_cubit.dart';
import '../manager/sub_category_actions_cubit/sub_category_actions_cubit.dart';
import './widgets/sub_category_view_body.dart';
import './widgets/sub_category_form_bottom_sheet.dart';

class SubCategoryView extends StatelessWidget {
  const SubCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<GetSubCategoriesCubit>()..add(GetAllSubCategoriesEvent())),
        BlocProvider(create: (context) => sl<SubCategoryActionsCubit>()),
      ],
      child: BlocBuilder<GetSubCategoriesCubit, GetSubCategoriesState>(
        builder: (context, state) {
          return CustomScaffold(
            title: "Sub-Categories",
            actions: [
              // Web gates Subcategories' mutations on manageCategories, not a
              // dedicated capability (SubCategoriesPage.tsx).
              manageCapability(
                capability: CapabilityKeys.manageCategories,
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: context.read<SubCategoryActionsCubit>()),
                          BlocProvider.value(value: context.read<GetSubCategoriesCubit>()),
                        ],
                        child: const SubCategoryFormBottomSheet(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle, size: 28),
                ),
              ),
            ],
            body: state.noConnection
                ? NoInternet(
                    onPressed: () {
                      context.read<GetSubCategoriesCubit>().add(GetAllSubCategoriesEvent());
                    },
                  )
                : const SubCategoryViewBody(),
          );
        },
      ),
    );
  }
}
