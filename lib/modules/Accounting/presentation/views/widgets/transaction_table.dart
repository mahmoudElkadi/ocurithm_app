import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';
import 'package:shimmer/shimmer.dart';

import '../../manager/account_details_cubit/account_details_cubit.dart';
import '../../manager/account_details_cubit/account_details_state.dart';
import '../widgets/transaction_card.dart';

class TransactionTable extends StatelessWidget {
  const TransactionTable({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountDetailsCubit, AccountDetailsState>(
      builder: (context, state) {
        if (state.transactions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 60, color: Colors.grey.withValues(alpha: 0.3)),
                  const HeightSpacer(size: 16),
                  Text(
                    "No transactions found",
                    style: appStyle(context, 16, Colors.grey, FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.transactions.length +
              (state.hasReachedMaxTransactions ? 0 : 1),
          separatorBuilder: (context, index) => const HeightSpacer(size: 12),
          itemBuilder: (context, index) {
            if (index >= state.transactions.length) {
              if (state.status ==
                  AccountDetailsStatus.loadingMoreTransactions) {
                return const _TransactionShimmerCard();
              }
              return _buildLoadMore(context);
            }
            final tx = state.transactions[index];
            return TransactionCard(
                transaction: tx, currentAccountId: state.account!.id!);
          },
        );
      },
    );
  }

  Widget _buildLoadMore(BuildContext context) {
    final cubit = context.read<AccountDetailsCubit>();
    final state = cubit.state;
    return InkWell(
      onTap: () => cubit.loadTransactions(state.account!.id!),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Text(
            "Load More Transactions",
            style: appStyle(
                context, 14, Theme.of(context).primaryColor, FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _TransactionShimmerCard extends StatelessWidget {
  const _TransactionShimmerCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
            ),
            const WidthSpacer(size: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8))),
                  const HeightSpacer(size: 8),
                  Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                    width: 70,
                    height: 16,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8))),
                const HeightSpacer(size: 8),
                Container(
                    width: 50,
                    height: 14,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
