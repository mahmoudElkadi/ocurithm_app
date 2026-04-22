import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';

import '../../../manager/account_actions_cubit/account_actions_cubit.dart';
import '../../../manager/account_details_cubit/account_details_cubit.dart';
import '../../../manager/account_details_cubit/account_details_state.dart';
import '../../widgets/transaction_form_bottom_sheet.dart';
import '../../widgets/transaction_table.dart';

class AccountDetailsBody extends StatelessWidget {
  const AccountDetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AccountDetailsCubit>().state;
    if (state.account == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(context, state),
          const HeightSpacer(size: 24),
          _buildQuickActions(context, state),
          const HeightSpacer(size: 24),
          _buildTransactionsHeader(context, state),
          const HeightSpacer(size: 16),
          const TransactionTable(),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, AccountDetailsState state) {
    final account = state.account!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [theme.primaryColor.withValues(alpha: 0.3), theme.cardColor]
              : [theme.primaryColor.withValues(alpha: 0.8), theme.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Balance",
                    style: appStyle(
                        context,
                        14,
                        isDark ? Colors.white70 : Colors.white70,
                        FontWeight.w500),
                  ),
                  Text(
                    "${account.currentBalance?.toStringAsFixed(2) ?? "0.00"} EGP",
                    style: appStyle(context, 32, Colors.white, FontWeight.w800),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet,
                    color: Colors.white, size: 32),
              ),
            ],
          ),
          const HeightSpacer(size: 24),
          Row(
            children: [
              _buildMiniInfo(context, "Initial Balance",
                  "${account.initialBalance?.toStringAsFixed(2) ?? "0.00"}"),
              const WidthSpacer(size: 32),
              _buildMiniInfo(context, "Type",
                  account.accountType?.toUpperCase() ?? "OTHER"),
            ],
          ),
          const HeightSpacer(size: 16),
          _buildMiniInfo(context, "Owner Reference",
              "${account.entityType ?? "N/A"} - ${account.entityId ?? "N/A"}"),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: appStyle(context, 12, Colors.white70, FontWeight.w500),
        ),
        Text(
          value,
          style: appStyle(context, 14, Colors.white, FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, AccountDetailsState state) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            "Transfer Out",
            Icons.unarchive,
            Colors.redAccent,
            () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(
                        value: context.read<AccountActionsCubit>()),
                  ],
                  child: TransactionFormBottomSheet(fromAccount: state.account),
                ),
              );
            },
          ),
        ),
        const WidthSpacer(size: 12),
        Expanded(
          child: _buildActionButton(
            context,
            "Transfer In",
            Icons.archive,
            Colors.greenAccent,
            () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(
                        value: context.read<AccountActionsCubit>()),
                  ],
                  child: TransactionFormBottomSheet(toAccount: state.account),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const HeightSpacer(size: 8),
            Text(
              label,
              style: appStyle(context, 14,
                  isDark ? Colors.white : Colors.black87, FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsHeader(
      BuildContext context, AccountDetailsState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Transactions",
          style: appStyle(
              context,
              20,
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              FontWeight.w700),
        ),
      ],
    );
  }
}
