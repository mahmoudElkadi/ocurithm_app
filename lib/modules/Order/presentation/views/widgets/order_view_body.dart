import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/search_fileld.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/modules/Order/presentation/manager/get_orders_cubit/get_orders_bloc.dart';
import 'package:ocurithm/modules/Order/presentation/manager/order_actions_cubit/order_actions_bloc.dart';
import './order_list_view.dart';

class OrderViewBody extends StatefulWidget {
  const OrderViewBody({super.key});

  @override
  State<OrderViewBody> createState() => _OrderViewBodyState();
}

class _OrderViewBodyState extends State<OrderViewBody> {
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
        BlocListener<GetOrdersBloc, GetOrdersState>(
          listenWhen: (previous, current) => previous.search != current.search,
          listener: (context, state) {
            if (state.search == '') {
              _searchController.text = '';
            } else if (_searchController.text != state.search) {
              _searchController.text = state.search;
            }
          },
        ),
        BlocListener<OrderActionsBloc, OrderActionsState>(
          listener: (context, state) {
            if (state.status == OrderActionsStatus.success) {
              SnackbarService.showSuccess(context, message: "Order processed successfully");
              context.read<GetOrdersBloc>().add(GetAllOrdersEvent());
            } else if (state.status == OrderActionsStatus.error) {
              SnackbarService.showError(context, message: state.errorMessage ?? "Error occurred");
            }
          },
        ),
      ],
      child: Column(
        children: [
          _buildSearchField(context),
          const HeightSpacer(size: 10),
          const OrderListView(),
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
              context.read<GetOrdersBloc>().onSearchChanged(
                    _searchController.text,
                  );
            },
            searchController: _searchController,
            onClose: () {
              _searchController.clear();
              context.read<GetOrdersBloc>().onSearchChanged('');
            },
          ),
        ),
        // Add Filter button here if needed
      ],
    );
  }
}
