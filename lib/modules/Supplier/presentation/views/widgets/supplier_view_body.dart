import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/search_fileld.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/modules/Supplier/presentation/manager/get_suppliers_cubit/get_suppliers_cubit.dart';
import 'package:ocurithm/modules/Supplier/presentation/manager/supplier_actions_cubit/supplier_actions_cubit.dart';
import './supplier_list_view.dart';

class SupplierViewBody extends StatefulWidget {
  const SupplierViewBody({super.key});

  @override
  State<SupplierViewBody> createState() => _SupplierViewBodyState();
}

class _SupplierViewBodyState extends State<SupplierViewBody> {
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
        BlocListener<GetSuppliersCubit, GetSuppliersState>(
          listenWhen: (previous, current) => previous.search != current.search,
          listener: (context, state) {
            if (state.search == '') {
              _searchController.text = '';
            } else if (_searchController.text != state.search) {
              _searchController.text = state.search;
            }
          },
        ),
        BlocListener<SupplierActionsCubit, SupplierActionsState>(
          listener: (context, state) {
            if (state.isSuccess) {
              if (state.successMessage != null) {
                SnackbarService.showSuccess(context,
                    message: state.successMessage!);
              }
              if (state.supplier != null) {
                context
                    .read<GetSuppliersCubit>()
                    .add(UpdateLocalSupplierEvent(state.supplier!));
              } else if (state.actingId != null) {
                context
                    .read<GetSuppliersCubit>()
                    .add(DeleteLocalSupplierEvent(state.actingId!));
              } else {
                context.read<GetSuppliersCubit>().add(GetAllSuppliersEvent());
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
          const SupplierListView(),
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
              context.read<GetSuppliersCubit>().onSearchChanged(
                    _searchController.text,
                  );
            },
            searchController: _searchController,
            onClose: () {
              _searchController.clear();
              context.read<GetSuppliersCubit>().onSearchChanged('');
            },
          ),
        ),
        // No filter bottom sheet for suppliers yet as per requirements (only search)
      ],
    );
  }
}
