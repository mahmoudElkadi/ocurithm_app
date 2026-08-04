import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/filter_icon_button.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/search_fileld.dart';
import 'package:ocurithm/modules/SubCategory/presentation/manager/get_sub_categories_cubit/get_sub_categories_cubit.dart';
import 'package:ocurithm/modules/SubCategory/presentation/manager/sub_category_actions_cubit/sub_category_actions_cubit.dart';
import 'sub_category_list_view.dart';
import 'sub_category_filter_bottom_sheet.dart';

class SubCategoryViewBody extends StatefulWidget {
  const SubCategoryViewBody({super.key});

  @override
  State<SubCategoryViewBody> createState() => _SubCategoryViewBodyState();
}

class _SubCategoryViewBodyState extends State<SubCategoryViewBody> {
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
        BlocListener<GetSubCategoriesCubit, GetSubCategoriesState>(
          listenWhen: (previous, current) => previous.search != current.search,
          listener: (context, state) {
            if (state.search == '') {
              _searchController.text = '';
            } else if (_searchController.text != state.search) {
              _searchController.text = state.search;
            }
          },
        ),
        BlocListener<SubCategoryActionsCubit, SubCategoryActionsState>(
          listener: (context, state) {
            if (state.isSuccess) {
              if (state.successMessage != null) {
                SnackbarService.showSuccess(context, message: state.successMessage!);
              }
              context.read<GetSubCategoriesCubit>().add(GetAllSubCategoriesEvent());
            } else if (state.isError) {
              SnackbarService.showError(
                context,
                message: state.errorMessage ?? "Error occurred",
              );
            }
          },
        ),
      ],
      child: Column(
        children: [
          _buildSearchField(context),
          const HeightSpacer(size: 10),
          const Expanded(child: SubCategoryListView()),
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
              context.read<GetSubCategoriesCubit>().onSearchChanged(
                    _searchController.text,
                  );
            },
            searchController: _searchController,
            onClose: () {
              _searchController.clear();
              context.read<GetSubCategoriesCubit>().onSearchChanged('');
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: BlocBuilder<GetSubCategoriesCubit, GetSubCategoriesState>(
            buildWhen: (previous, current) =>
                previous.clinicFilter != current.clinicFilter ||
                previous.categoryFilter != current.categoryFilter,
            builder: (context, state) {
              final activeCount = [
                state.clinicFilter,
                state.categoryFilter,
              ].where((v) => v != null).length;
              return FilterIconButton(
                activeCount: activeCount,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BlocProvider.value(
                      value: context.read<GetSubCategoriesCubit>(),
                      child: const SubCategoryFilterBottomSheet(),
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}
