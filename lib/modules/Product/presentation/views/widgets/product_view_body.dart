import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/search_fileld.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/modules/Product/presentation/manager/get_products_cubit/get_products_cubit.dart';
import 'package:ocurithm/modules/Product/presentation/manager/product_actions_cubit/product_actions_cubit.dart';
import './product_filter_bottom_sheet.dart';
import './product_list_view.dart';

class ProductViewBody extends StatefulWidget {
  const ProductViewBody({super.key});

  @override
  State<ProductViewBody> createState() => _ProductViewBodyState();
}

class _ProductViewBodyState extends State<ProductViewBody> {
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
        BlocListener<GetProductsCubit, GetProductsState>(
          listenWhen: (previous, current) => previous.search != current.search,
          listener: (context, state) {
            if (state.search == '') {
              _searchController.text = '';
            } else if (_searchController.text != state.search) {
              _searchController.text = state.search;
            }
          },
        ),
        BlocListener<ProductActionsCubit, ProductActionsState>(
          listener: (context, state) {
            if (state.isSuccess) {
              if (state.successMessage != null) {
                SnackbarService.showSuccess(context,
                    message: state.successMessage!);
              }
              if (state.product != null) {
                final exists = context
                        .read<GetProductsCubit>()
                        .state
                        .products
                        ?.products
                        .any((p) => p.id == state.product!.id) ??
                    false;
                if (exists) {
                  context
                      .read<GetProductsCubit>()
                      .add(UpdateLocalProductEvent(state.product!));
                } else {
                  context
                      .read<GetProductsCubit>()
                      .add(AddLocalProductEvent(state.product!));
                }
              } else if (state.actingId != null) {
                // If product is null but actingId exists, it's a deletion
                context
                    .read<GetProductsCubit>()
                    .add(DeleteLocalProductEvent(state.actingId!));
              } else {
                context.read<GetProductsCubit>().add(GetAllProductsEvent());
              }
            } else if (state.isError) {
              SnackbarService.showError(context,
                  message: state.errorMessage ?? "Error occurred");
            }
          },
        ),
      ],
      child: Column(
        children: [
          _buildSearchField(context),
          const HeightSpacer(size: 10),
          const ProductListView(),
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
              context.read<GetProductsCubit>().onSearchChanged(
                    _searchController.text,
                  );
            },
            searchController: _searchController,
            onClose: () {
              _searchController.clear();
              context.read<GetProductsCubit>().onSearchChanged('');
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: InkWell(
            onTap: () {
              showFilterBottomSheet(context);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.tune,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
          ),
        )
      ],
    );
  }

  void showFilterBottomSheet(BuildContext context) {
    final cubit = context.read<GetProductsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductFilterBottomSheet(
        getProductsCubit: cubit,
      ),
    );
  }
}
