import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/search_fileld.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/modules/PurchaseOrder/presentation/manager/get_purchase_orders_cubit/get_purchase_orders_cubit.dart';
import 'package:ocurithm/modules/PurchaseOrder/presentation/manager/purchase_order_actions_cubit/purchase_order_actions_cubit.dart';
import './purchase_order_list_view.dart';

class PurchaseOrderViewBody extends StatefulWidget {
  const PurchaseOrderViewBody({super.key});

  @override
  State<PurchaseOrderViewBody> createState() => _PurchaseOrderViewBodyState();
}

class _PurchaseOrderViewBodyState extends State<PurchaseOrderViewBody> {
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
        BlocListener<GetPurchaseOrdersCubit, GetPurchaseOrdersState>(
          listenWhen: (previous, current) => previous.search != current.search,
          listener: (context, state) {
            if (state.search == '') {
              _searchController.text = '';
            } else if (_searchController.text != state.search) {
              _searchController.text = state.search;
            }
          },
        ),
        BlocListener<PurchaseOrderActionsCubit, PurchaseOrderActionsState>(
          listener: (context, state) {
            if (state.isSuccess && state.successMessage != null) {
              SnackbarService.showSuccess(context, message: state.successMessage!);
              context.read<GetPurchaseOrdersCubit>().add(GetAllPurchaseOrdersEvent());
            } else if (state.isError) {
              SnackbarService.showError(context, message: state.errorMessage ?? "Error occurred");
            }
          },
        ),
      ],
      child: Column(
        children: [
          _buildSearchField(context),
          const HeightSpacer(size: 10),
          const PurchaseOrderListView(),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SearchField(
        onTextFieldChanged: () async {
          context.read<GetPurchaseOrdersCubit>().onSearchChanged(
                _searchController.text,
              );
        },
        searchController: _searchController,
        onClose: () {
          _searchController.clear();
          context.read<GetPurchaseOrdersCubit>().onSearchChanged('');
        },
      ),
    );
  }
}
