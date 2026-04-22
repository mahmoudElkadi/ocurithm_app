import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/search_fileld.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import '../../manager/get_accounts_cubit/get_accounts_cubit.dart';
import '../../manager/get_accounts_cubit/get_accounts_event.dart';
import '../../manager/account_actions_cubit/account_actions_cubit.dart';
import '../../manager/account_actions_cubit/account_actions_state.dart';
import './accounts_list_view.dart';
import './accounts_filter_bottom_sheet.dart';

class AccountsViewBody extends StatefulWidget {
  const AccountsViewBody({super.key});

  @override
  State<AccountsViewBody> createState() => _AccountsViewBodyState();
}

class _AccountsViewBodyState extends State<AccountsViewBody> {
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
        BlocListener<AccountActionsCubit, AccountActionsState>(
          listener: (context, state) {
            if (state.status == AccountActionsStatus.success) {
              if (state.successMessage != null) {
                SnackbarService.showSuccess(context,
                    message: state.successMessage!);
              }
              // Refresh the list
              context.read<GetAccountsCubit>().add(ResetAccountFilters());
            } else if (state.status == AccountActionsStatus.failure) {
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
          const AccountsListView(),
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
              context.read<GetAccountsCubit>().add(GetAllAccountsEvent(
                    search: _searchController.text,
                    clinic: context.read<GetAccountsCubit>().state.clinic,
                    accountType:
                        context.read<GetAccountsCubit>().state.accountType,
                    entityType:
                        context.read<GetAccountsCubit>().state.entityType,
                    isActive: context.read<GetAccountsCubit>().state.isActive,
                  ));
            },
            searchController: _searchController,
            onClose: () {
              _searchController.clear();
              context.read<GetAccountsCubit>().add(ResetAccountFilters());
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
    final cubit = context.read<GetAccountsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AccountsFilterBottomSheet(
        getAccountsCubit: cubit,
      ),
    );
  }
}
