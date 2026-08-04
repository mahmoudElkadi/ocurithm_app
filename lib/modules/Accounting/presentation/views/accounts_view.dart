import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/manage_capabilities.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';

import '../manager/account_actions_cubit/account_actions_cubit.dart';
import '../manager/account_actions_cubit/account_actions_state.dart';
import '../manager/get_accounts_cubit/get_accounts_cubit.dart';
import '../manager/get_accounts_cubit/get_accounts_event.dart';
import '../manager/get_accounts_cubit/get_accounts_state.dart';
import 'account_form/account_form_bottom_sheet.dart';
import 'widgets/accounts_view_body.dart';

class AccountsView extends StatelessWidget {
  const AccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<GetAccountsCubit>()..add(GetAllAccountsEvent()),
        ),
        BlocProvider(
          create: (context) => sl<AccountActionsCubit>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocListener(
            listeners: [
              BlocListener<AccountActionsCubit, AccountActionsState>(
                listener: (context, state) {
                  if (state.status == AccountActionsStatus.success) {
                    if (state.successMessage != null) {
                      SnackbarService.showSuccess(context,
                          message: state.successMessage!);
                    }
                    context.read<GetAccountsCubit>().add(ResetAccountFilters());
                  } else if (state.status == AccountActionsStatus.failure) {
                    SnackbarService.showError(context,
                        message: state.errorMessage ?? "Error occurred");
                  }
                },
              ),
            ],
            child: BlocBuilder<GetAccountsCubit, GetAccountsState>(
              builder: (context, state) {
                return CustomScaffold(
                  title: "Accounts",
                  actions: [
                    manageCapability(
                      capability: CapabilityKeys.manageAccounts,
                      child: IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(
                                    value: context.read<AccountActionsCubit>()),
                                BlocProvider.value(
                                    value: context.read<GetAccountsCubit>()),
                              ],
                              child: const AccountFormBottomSheet(),
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
                            context
                                .read<GetAccountsCubit>()
                                .add(GetAllAccountsEvent());
                          },
                        )
                      : CustomMaterialIndicator(
                          onRefresh: () async {
                            context
                                .read<GetAccountsCubit>()
                                .add(ResetAccountFilters());
                          },
                          indicatorBuilder: (BuildContext context,
                              IndicatorController controller) {
                            return const Image(
                                image: AssetImage("assets/icons/logo.png"));
                          },
                          child: const SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: AccountsViewBody(),
                          ),
                        ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
