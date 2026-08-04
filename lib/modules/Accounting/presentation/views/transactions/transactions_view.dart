import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/filter_icon_button.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/manage_capabilities.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/core/widgets/search_fileld.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/account_actions_cubit/account_actions_cubit.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/account_actions_cubit/account_actions_state.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/get_transactions_cubit/get_transactions_cubit.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/get_transactions_cubit/get_transactions_event.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/get_transactions_cubit/get_transactions_state.dart';

import '../widgets/transaction_card.dart';
import '../widgets/transaction_form_bottom_sheet.dart';
import '../widgets/transaction_shimmer.dart';
import 'widgets/transactions_filter_sheet.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<GetTransactionsCubit>()..add(GetAllTransactionsEvent()),
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
                    context
                        .read<GetTransactionsCubit>()
                        .add(ResetTransactionFilters());
                  } else if (state.status == AccountActionsStatus.failure) {
                    SnackbarService.showError(context,
                        message: state.errorMessage ?? "Error occurred");
                  }
                },
              ),
            ],
            child: CustomScaffold(
              title: "Transactions History",
              actions: [
                manageCapability(
                  capability: CapabilityKeys.manageTransactions,
                  child: IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => BlocProvider.value(
                          value: context.read<AccountActionsCubit>(),
                          child: const TransactionFormBottomSheet(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle, size: 28),
                  ),
                ),
              ],
              body: Column(
                children: [
                  _buildSearchField(context),
                  const HeightSpacer(size: 10),
                  Expanded(
                    child: CustomMaterialIndicator(
                      onRefresh: () async {
                        context
                            .read<GetTransactionsCubit>()
                            .add(ResetTransactionFilters());
                      },
                      indicatorBuilder: (BuildContext context,
                          IndicatorController controller) {
                        return const Image(
                            image: AssetImage("assets/icons/logo.png"));
                      },
                      child: const SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: TransactionsListBody(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchField(
            onTextFieldChanged: () async {
              final state = context.read<GetTransactionsCubit>().state;
              context.read<GetTransactionsCubit>().add(GetAllTransactionsEvent(
                    search: _searchController.text,
                    direction: state.direction,
                    source: state.source,
                    accountId: state.accountId,
                    fromAccount: state.fromAccount,
                    toAccount: state.toAccount,
                    startDate: state.startDate,
                    endDate: state.endDate,
                  ));
            },
            searchController: _searchController,
            onClose: () {
              _searchController.clear();
              context
                  .read<GetTransactionsCubit>()
                  .add(ResetTransactionFilters());
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: BlocBuilder<GetTransactionsCubit, GetTransactionsState>(
            buildWhen: (previous, current) =>
                previous.clinic != current.clinic ||
                previous.accountId != current.accountId ||
                previous.fromAccount != current.fromAccount ||
                previous.toAccount != current.toAccount ||
                previous.source != current.source ||
                previous.startDate != current.startDate,
            builder: (context, state) {
              final activeCount = [
                state.clinic,
                state.accountId,
                state.fromAccount,
                state.toAccount,
                state.source,
                state.startDate,
              ].where((v) => v != null).length;
              return FilterIconButton(
                activeCount: activeCount,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BlocProvider.value(
                      value: context.read<GetTransactionsCubit>(),
                      child: const TransactionsFilterSheet(),
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}

class TransactionsListBody extends StatefulWidget {
  const TransactionsListBody({super.key});

  @override
  State<TransactionsListBody> createState() => _TransactionsListBodyState();
}

class _TransactionsListBodyState extends State<TransactionsListBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<GetTransactionsCubit>().add(LoadMoreTransactionsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetTransactionsCubit, GetTransactionsState>(
      builder: (context, state) {
        if (state.status == GetTransactionsStatus.loading ||
            state.status == GetTransactionsStatus.initial) {
          return const TransactionShimmer();
        }

        if (state.status == GetTransactionsStatus.failure &&
            state.transactions.isEmpty) {
          return Center(
              child: Text(state.errorMessage ?? "Error loading transactions"));
        }

        if (state.status == GetTransactionsStatus.success &&
            state.transactions.isEmpty) {
          return const Center(child: Text("No transactions found"));
        }

        return ListView.separated(
          controller: _scrollController,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: state.transactions.length + (state.hasReachedMax ? 0 : 1),
          separatorBuilder: (context, index) => const HeightSpacer(size: 12),
          itemBuilder: (context, index) {
            if (index >= state.transactions.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return TransactionCard(transaction: state.transactions[index]);
          },
        );
      },
    );
  }
}
