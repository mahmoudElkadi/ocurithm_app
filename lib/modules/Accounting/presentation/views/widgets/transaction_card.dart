import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';
import 'package:ocurithm/core/utils/capability_services.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';
import '../../../data/models/transaction_model.dart';
import './transaction_details_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/account_actions_cubit/account_actions_cubit.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/account_actions_cubit/account_actions_event.dart';
import './transaction_form_bottom_sheet.dart';

class TransactionCard extends StatelessWidget {
  final AccountTransaction transaction;
  final String? currentAccountId; // Optional: if provided, determines IN/OUT icon

  const TransactionCard({
    super.key, 
    required this.transaction, 
    this.currentAccountId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // If currentAccountId is null (global list), we determine direction by context
    // For global list, maybe we just show if it's a transfer or a payment
    final bool isIncoming = currentAccountId != null && transaction.toAccount?.id == currentAccountId;
    final otherParty = currentAccountId != null 
        ? (isIncoming ? transaction.fromAccount?.name : transaction.toAccount?.name)
        : "${transaction.fromAccount?.name ?? "External"} → ${transaction.toAccount?.name ?? "External"}";
    
    final DateTime displayDate = transaction.date ?? transaction.createdAt ?? DateTime.now();
    final String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(displayDate);

    return InkWell(
      onTap: () => _showTransactionDetails(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: theme.primaryColor.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (currentAccountId == null ? theme.primaryColor : (isIncoming ? Colors.green : Colors.red)).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                currentAccountId == null 
                    ? Icons.swap_horiz 
                    : (isIncoming ? Icons.south_west : Icons.north_east),
                color: currentAccountId == null ? theme.primaryColor : (isIncoming ? Colors.green : Colors.red),
                size: 20,
              ),
            ),
            const WidthSpacer(size: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherParty ?? "External Source",
                    style: appStyle(context, 14, isDark ? Colors.white : Colors.black87, FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const HeightSpacer(size: 4),
                  Text(
                    formattedDate,
                    style: appStyle(context, 12, Colors.grey, FontWeight.w500),
                  ),
                ],
              ),
            ),
            const WidthSpacer(size: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${(currentAccountId != null) ? (isIncoming ? "+" : "-") : ""}${transaction.amount?.toStringAsFixed(2) ?? "0.00"} EGP",
                      style: appStyle(
                        context, 
                        16, 
                        currentAccountId == null ? theme.primaryColor : (isIncoming ? Colors.green : Colors.red), 
                        FontWeight.w800
                      ),
                    ),
                    if (CapabilityServices.hasCapability(
                            CapabilityKeys.manageTransactions) &&
                        (transaction.source ?? "manual") == "manual") ...[
                      const WidthSpacer(size: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _handleEdit(context);
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(context, context.read<AccountActionsCubit>());
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Update'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                        child: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 22),
                      ),
                    ],
                  ],
                ),
                const HeightSpacer(size: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (transaction.source ?? "manual").toUpperCase(),
                    style: appStyle(context, 10, theme.primaryColor, FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleEdit(BuildContext context) {
    final cubit = context.read<AccountActionsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: TransactionFormBottomSheet(transaction: transaction),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailsBottomSheet(
        transaction: transaction,
        currentAccountId: currentAccountId,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AccountActionsCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Transaction"),
        content: const Text("Are you sure you want to delete this transaction? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              cubit.add(DeleteTransactionEvent(transaction.id!));
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
