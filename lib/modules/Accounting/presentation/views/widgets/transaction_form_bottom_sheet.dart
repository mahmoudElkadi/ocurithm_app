import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/text_field.dart';

import '../../../data/models/account_model.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/account_actions_cubit/account_actions_cubit.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/account_actions_cubit/account_actions_event.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/account_actions_cubit/account_actions_state.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/get_accounts_cubit/get_accounts_cubit.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/get_accounts_cubit/get_accounts_event.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/get_accounts_cubit/get_accounts_state.dart';

import '../../../data/models/transaction_model.dart';

class TransactionFormBottomSheet extends StatefulWidget {
  final Account? fromAccount;
  final Account? toAccount;
  final AccountTransaction? transaction;

  const TransactionFormBottomSheet({
    super.key, 
    this.fromAccount, 
    this.toAccount,
    this.transaction,
  });

  @override
  State<TransactionFormBottomSheet> createState() =>
      _TransactionFormBottomSheetState();
}

class _TransactionFormBottomSheetState
    extends State<TransactionFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  String? _selectedSource;
  String? _selectedFromAccountId;
  String? _selectedToAccountId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction?.amount?.toString());
    _noteController = TextEditingController(text: widget.transaction?.note);
    _selectedSource = widget.transaction?.source ?? "manual";
    _selectedFromAccountId = widget.transaction?.fromAccount?.id ?? widget.fromAccount?.id;
    _selectedToAccountId = widget.transaction?.toAccount?.id ?? widget.toAccount?.id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFromAccountId == null || _selectedToAccountId == null) {
      SnackbarService.showError(context,
          message: "Please select both accounts");
      return;
    }

    if (_selectedFromAccountId == _selectedToAccountId) {
      SnackbarService.showError(context,
          message: "Cannot transfer to same account");
      return;
    }

    final double amount = double.tryParse(_amountController.text) ?? 0;

    if (widget.transaction != null) {
      context.read<AccountActionsCubit>().add(UpdateTransactionEvent(
            id: widget.transaction!.id!,
            fromAccountId: _selectedFromAccountId,
            toAccountId: _selectedToAccountId,
            amount: amount,
            source: _selectedSource,
            note: _noteController.text.trim(),
            date: widget.transaction!.date,
          ));
    } else {
      context.read<AccountActionsCubit>().add(AddTransactionEvent(
            fromAccountId: _selectedFromAccountId!,
            toAccountId: _selectedToAccountId!,
            amount: amount,
            source: _selectedSource,
            note: _noteController.text.trim(),
            date: DateTime.now(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<GetAccountsCubit>()..add(GetAllAccountsEvent(limit: 100)),
        ),
      ],
      child: BlocListener<AccountActionsCubit, AccountActionsState>(
        listener: (context, state) {
          if (state.status == AccountActionsStatus.success) {
            Navigator.pop(context);
          }
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: BlocBuilder<GetAccountsCubit, GetAccountsState>(
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.transaction != null ? "Update Transaction" : "Add Transaction",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const HeightSpacer(size: 20),
                      DropdownItem(
                        radius: 30,
                        color: theme.cardColor,
                        isShadow: false,
                        label: "From Account",
                        border: Colors.grey.shade300,
                        items: state.accounts,
                        disabledItems: state.accounts
                            .where((a) => a.id == _selectedToAccountId)
                            .toList(),
                        selectedValue: widget.fromAccount != null
                            ? widget.fromAccount!.name
                            : state.accounts
                                .where((a) => a.id == _selectedFromAccountId)
                                .firstOrNull
                                ?.name,
                        hintText: "Select account",
                        itemAsString: (item) {
                          final a = item as Account;
                          return "${a.name ?? ""} (${a.currentBalance?.toStringAsFixed(2) ?? "0.00"} EGP)";
                        },
                        onItemSelected: (item) => setState(() =>
                            _selectedFromAccountId = (item as Account).id),
                        readOnly: widget.fromAccount != null,
                        isLoading: state.status == GetAccountsStatus.loading,
                      ),
                      const HeightSpacer(size: 15),
                      DropdownItem(
                        radius: 30,
                        color: theme.cardColor,
                        isShadow: false,
                        label: "To Account",
                        border: Colors.grey.shade300,
                        items: state.accounts,
                        disabledItems: state.accounts
                            .where((a) => a.id == _selectedFromAccountId)
                            .toList(),
                        selectedValue: widget.toAccount != null
                            ? widget.toAccount!.name
                            : state.accounts
                                .where((a) => a.id == _selectedToAccountId)
                                .firstOrNull
                                ?.name,
                        hintText: "Select account",
                        itemAsString: (item) {
                          final a = item as Account;
                          return "${a.name ?? ""} (${a.currentBalance?.toStringAsFixed(2) ?? "0.00"} EGP)";
                        },
                        onItemSelected: (item) => setState(
                            () => _selectedToAccountId = (item as Account).id),
                        readOnly: widget.toAccount != null,
                        isLoading: state.status == GetAccountsStatus.loading,
                      ),
                      const HeightSpacer(size: 15),
                      TextField2(
                        controller: _amountController,
                        text: "Amount",
                        required: true,
                        radius: 30,
                        fillColor: theme.cardColor,
                        isShadow: false,
                        border: Colors.grey.shade300,
                        hintText: "0.00",
                        type: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return "Amount is required";
                          if ((double.tryParse(v) ?? 0) <= 0)
                            return "Amount must be > 0";
                          return null;
                        },
                      ),
                      const HeightSpacer(size: 15),
                      TextField2(
                        controller: _noteController,
                        text: "Note",
                        required: false,
                        radius: 30,
                        fillColor: theme.cardColor,
                        isShadow: false,
                        border: Colors.grey.shade300,
                        hintText: "Optional note info",
                      ),
                      const HeightSpacer(size: 25),
                      BlocBuilder<AccountActionsCubit, AccountActionsState>(
                        builder: (context, actionState) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: actionState.status ==
                                    AccountActionsStatus.loading
                                ? null
                                : _handleSubmit,
                            child: actionState.status ==
                                    AccountActionsStatus.loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(widget.transaction != null ? "Update" : "Transfer",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
