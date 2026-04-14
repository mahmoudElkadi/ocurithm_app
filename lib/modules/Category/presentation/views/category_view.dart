import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Category/presentation/views/widgets/category_form_bottom_sheet.dart';

import '../../../../core/utils/services_locator.dart';
import '../manager/category_actions_cubit/category_actions_cubit.dart';
import '../manager/get_categories_cubit/get_categories_cubit.dart';
import './widgets/category_view_body.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                sl<GetCategoriesCubit>()..add(GetAllCategoriesEvent())),
        BlocProvider(create: (context) => sl<CategoryActionsCubit>()),
      ],
      child: BlocBuilder<GetCategoriesCubit, GetCategoriesState>(
        builder: (context, state) {
          return CustomScaffold(
            title: "Categories",
            actions: [
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                            value: context.read<CategoryActionsCubit>()),
                        BlocProvider.value(
                            value: context.read<GetCategoriesCubit>()),
                      ],
                      child: CategoryFormBottomSheet(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle, size: 28),
              ),
            ],
            body: state.noConnection
                ? NoInternet(
                    onPressed: () {
                      context
                          .read<GetCategoriesCubit>()
                          .add(GetAllCategoriesEvent());
                    },
                  )
                : CustomMaterialIndicator(
                    onRefresh: () async {
                      context
                          .read<GetCategoriesCubit>()
                          .add(ResetCategoryFilters());
                    },
                    indicatorBuilder:
                        (BuildContext context, IndicatorController controller) {
                      return const Image(
                          image: AssetImage("assets/icons/logo.png"));
                    },
                    child: const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: CategoryViewBody(),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
