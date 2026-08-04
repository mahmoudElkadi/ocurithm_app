import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/filter_icon_button.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/search_fileld.dart';

import '../../manager/get_categories_cubit/get_categories_cubit.dart';
import '../../manager/category_actions_cubit/category_actions_cubit.dart';
import './category_filter_bottom_sheet.dart';
import './category_list_view.dart';

class CategoryViewBody extends StatefulWidget {
  const CategoryViewBody({super.key});

  @override
  State<CategoryViewBody> createState() => _CategoryViewBodyState();
}

class _CategoryViewBodyState extends State<CategoryViewBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GetCategoriesCubit, GetCategoriesState>(
          listenWhen: (previous, current) => previous.search != current.search,
          listener: (context, state) {
            if (state.search == '') {
              _searchController.text = '';
            } else if (_searchController.text != state.search) {
              _searchController.text = state.search;
            }
          },
        ),
        BlocListener<CategoryActionsCubit, CategoryActionsState>(
          listener: (context, state) {
            if (state.isSuccess) {
              if (state.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.successMessage!),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              context.read<GetCategoriesCubit>().add(GetAllCategoriesEvent());
            } else if (state.isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? "Error occurred"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: Column(
        children: [
          _buildSearchField(context),
          const HeightSpacer(size: 10),
          const CategoryListView(),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchField(
            onTextFieldChanged: () async {
              context.read<GetCategoriesCubit>().onSearchChanged(
                    _searchController.text,
                  );
            },
            searchController: _searchController,
            onClose: () {
              _searchController.clear();
              context.read<GetCategoriesCubit>().onSearchChanged('');
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: BlocBuilder<GetCategoriesCubit, GetCategoriesState>(
            buildWhen: (previous, current) =>
                previous.clinicFilter != current.clinicFilter,
            builder: (context, state) {
              return FilterIconButton(
                activeCount: state.clinicFilter != null ? 1 : 0,
                onTap: () {
                  showFilterBottomSheet(context);
                },
              );
            },
          ),
        )
      ],
    );
  }

  void showFilterBottomSheet(BuildContext context) {
    final cubit = context.read<GetCategoriesCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryFilterBottomSheet(
        getCategoriesCubit: cubit,
      ),
    );
  }
}
