import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';

import '../../../data/models/transaction_model.dart';

class TransactionDetailsBottomSheet extends StatelessWidget {
  final AccountTransaction transaction;
  final String? currentAccountId;

  const TransactionDetailsBottomSheet({
    super.key,
    required this.transaction,
    this.currentAccountId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool? isIncoming = currentAccountId != null
        ? transaction.toAccount?.id == currentAccountId
        : null;
    final DateTime displayDate =
        transaction.date ?? transaction.createdAt ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const HeightSpacer(size: 24),
          Text(
            "Transaction Details",
            style: appStyle(context, 20, isDark ? Colors.white : Colors.black,
                FontWeight.w800),
          ),
          const HeightSpacer(size: 24),

          // Amount Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Amount",
                        style: appStyle(
                            context, 12, Colors.grey, FontWeight.w600)),
                    const HeightSpacer(size: 4),
                    Text(
                      "${transaction.amount?.toStringAsFixed(2) ?? "0.00"} EGP",
                      style: appStyle(
                          context,
                          24,
                          isIncoming == null
                              ? theme.primaryColor
                              : (isIncoming ? Colors.green : Colors.red),
                          FontWeight.w800),
                    ),
                  ],
                ),
                if (isIncoming != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isIncoming ? Colors.green : Colors.red)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      isIncoming ? "INCOMING" : "OUTGOING",
                      style: appStyle(
                          context,
                          12,
                          isIncoming ? Colors.green : Colors.red,
                          FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),

          const HeightSpacer(size: 24),

          // From -> To Section
          _buildInfoRow(
              context,
              "From",
              transaction.fromAccount?.name ?? "External Source",
              Icons.upload_outlined),
          const Padding(
            padding: EdgeInsets.only(left: 45),
            child: Icon(Icons.arrow_downward, size: 20, color: Colors.grey),
          ),
          _buildInfoRow(
              context,
              "To",
              transaction.toAccount?.name ?? "External Source",
              Icons.download_outlined),

          const Divider(height: 40),

          _buildDetailItem(
              context,
              "Date & Time",
              DateFormat('dd MMMM yyyy, hh:mm a').format(displayDate),
              Icons.calendar_today_outlined),
          const HeightSpacer(size: 16),
          _buildDetailItem(
              context,
              "Source",
              (transaction.source ?? "manual").toUpperCase(),
              Icons.info_outline),

          if (transaction.note != null && transaction.note!.isNotEmpty) ...[
            const HeightSpacer(size: 16),
            _buildDetailItem(
                context, "Note", transaction.note!, Icons.notes_outlined),
          ],

          const HeightSpacer(size: 32),

          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: Text("Close",
                style: appStyle(context, 16, Colors.white, FontWeight.w700)),
          ),
          const HeightSpacer(size: 10),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Colors.grey),
        ),
        const WidthSpacer(size: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: appStyle(context, 12, Colors.grey, FontWeight.w500)),
            Text(value,
                style: appStyle(
                    context,
                    15,
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                    FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(
      BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon,
            size: 18,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.7)),
        const WidthSpacer(size: 12),
        Text("$label:",
            style: appStyle(context, 14, Colors.grey, FontWeight.w500)),
        const WidthSpacer(size: 8),
        Expanded(
          child: Text(
            value,
            style: appStyle(
                context,
                14,
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
                FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
