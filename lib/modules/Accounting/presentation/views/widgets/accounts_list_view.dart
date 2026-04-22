import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import '../../manager/get_accounts_cubit/get_accounts_cubit.dart';
import '../../manager/get_accounts_cubit/get_accounts_event.dart';
import '../../manager/get_accounts_cubit/get_accounts_state.dart';
import './account_card.dart';

class AccountsListView extends StatefulWidget {
  const AccountsListView({super.key});

  @override
  State<AccountsListView> createState() => _AccountsListViewState();
}

class _AccountsListViewState extends State<AccountsListView> {
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
      context.read<GetAccountsCubit>().add(LoadMoreAccountsEvent());
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
    return BlocBuilder<GetAccountsCubit, GetAccountsState>(
      builder: (context, state) {
        if (state.status == GetAccountsStatus.loading || state.status == GetAccountsStatus.initial) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemBuilder: (context, index) => const AccountCard(isLoading: true),
            separatorBuilder: (context, index) => const HeightSpacer(size: 15),
            itemCount: 5,
          );
        }

        if (state.status == GetAccountsStatus.failure && state.accounts.isEmpty) {
          return Center(child: Text(state.errorMessage ?? "Error loading accounts"));
        }

        if (state.status == GetAccountsStatus.success && state.accounts.isEmpty) {
          return const Center(child: Text("No accounts found"));
        }

        return ListView.separated(
          controller: _scrollController,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: state.hasReachedMax 
              ? state.accounts.length 
              : state.accounts.length + 1,
          separatorBuilder: (context, index) => const HeightSpacer(size: 15),
          itemBuilder: (context, index) {
            if (index >= state.accounts.length) {
              return const AccountCard(isLoading: true);
            }
            return AccountCard(account: state.accounts[index]);
          },
        );
      },
    );
  }
}
