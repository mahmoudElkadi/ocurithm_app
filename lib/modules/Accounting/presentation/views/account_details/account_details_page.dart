import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/services_locator.dart';

import '../../manager/account_actions_cubit/account_actions_cubit.dart';
import '../../manager/account_actions_cubit/account_actions_state.dart';
import '../../manager/account_details_cubit/account_details_cubit.dart';
import '../../manager/account_details_cubit/account_details_state.dart';
import 'widgets/account_details_body.dart';

class AccountDetailsPage extends StatelessWidget {
  final String accountId;

  const AccountDetailsPage({super.key, required this.accountId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<AccountDetailsCubit>()..loadAccountDetails(accountId),
        ),
        BlocProvider(
          create: (context) => sl<AccountActionsCubit>(),
        ),
      ],
      child: BlocListener<AccountActionsCubit, AccountActionsState>(
        listener: (context, state) {
          if (state.status == AccountActionsStatus.success) {
            context.read<AccountDetailsCubit>().loadAccountDetails(accountId);
          }
        },
        child: BlocBuilder<AccountDetailsCubit, AccountDetailsState>(
          builder: (context, state) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: theme.scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  state.account?.name ?? "Account Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                centerTitle: true,
              ),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AccountDetailsState state) {
    if (state.status == AccountDetailsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == AccountDetailsStatus.failure) {
      return Center(child: Text(state.errorMessage ?? "Error loading details"));
    }
    if (state.account == null) {
      return const Center(child: Text("Account not found"));
    }

    return const SingleChildScrollView(
      child: AccountDetailsBody(),
    );
  }
}
