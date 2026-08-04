import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';
import 'package:ocurithm/core/utils/capability_services.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/account_model.dart';
import '../../manager/account_actions_cubit/account_actions_cubit.dart';
import '../../manager/account_actions_cubit/account_actions_event.dart';
import '../../manager/get_accounts_cubit/get_accounts_cubit.dart';
import '../account_details/account_details_page.dart';
import '../account_form/account_form_bottom_sheet.dart';
import './transaction_form_bottom_sheet.dart';

class AccountCard extends StatelessWidget {
  final Account? account;
  final bool isLoading;

  const AccountCard({super.key, this.account, this.isLoading = false});

  Widget _buildShimmer(Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                    _buildShimmer(Container(
                      width: 150,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )),
                    const SizedBox(height: 8),
                    _buildShimmer(Container(
                      width: 80,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )),
                  ],
                ),
                _buildShimmer(Container(
                  width: 100,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                )),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _buildShimmer(Container(
                  width: 120,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                )),
                const Spacer(),
                _buildShimmer(Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                )),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AccountDetailsPage(accountId: account!.id!),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account?.name ?? "Unnamed Account",
                            style: appStyle(
                                context,
                                18,
                                isDark ? Colors.white : Colors.black,
                                FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            account?.accountType?.toUpperCase() ?? "OTHER",
                            style: appStyle(context, 12, theme.primaryColor,
                                FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    _buildBalanceBadge(context, account?.currentBalance ?? 0),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    _buildInfoItem(context, Icons.business,
                        account?.clinic?.name ?? "N/A"),
                    const Spacer(),
                    _buildStatusChip(context, account?.isActive ?? false),
                    const SizedBox(width: 8),
                    if (CapabilityServices.hasCapability(
                        CapabilityKeys.manageAccounts))
                      _buildActionsMenu(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceBadge(BuildContext context, num balance) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "${balance.toStringAsFixed(2)} EGP",
        style: appStyle(context, 16, theme.primaryColor, FontWeight.w700),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: appStyle(context, 14, Colors.grey, FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.red).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: appStyle(
            context, 12, isActive ? Colors.green : Colors.red, FontWeight.w600),
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text("Edit"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'transaction_from',
          child: Row(
            children: [
              Icon(Icons.unarchive, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text("Transfer From"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'transaction_to',
          child: Row(
            children: [
              Icon(Icons.archive, size: 20, color: Colors.green),
              SizedBox(width: 8),
              Text("Transfer To"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete,
                  size: 20, color: Colors.red.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              const Text("Delete", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    if (action == 'edit') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AccountActionsCubit>()),
            BlocProvider.value(value: context.read<GetAccountsCubit>()),
          ],
          child: AccountFormBottomSheet(account: account),
        ),
      );
    } else if (action == 'delete') {
      _showDeleteDialog(context);
    } else if (action == 'transaction_from') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AccountActionsCubit>()),
          ],
          child: TransactionFormBottomSheet(fromAccount: account),
        ),
      );
    } else if (action == 'transaction_to') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AccountActionsCubit>()),
          ],
          child: TransactionFormBottomSheet(toAccount: account),
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete this account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<AccountActionsCubit>()
                  .add(DeleteAccountEvent(account!.id!));
              Navigator.pop(dialogContext);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
