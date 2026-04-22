import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ocurithm/core/utils/app_style.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/modules/Accounting/data/models/account_model.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/get_accounts_cubit/get_accounts_cubit.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/get_accounts_cubit/get_accounts_event.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/get_accounts_cubit/get_accounts_state.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/get_transactions_cubit/get_transactions_cubit.dart';
import 'package:ocurithm/modules/Accounting/presentation/manager/get_transactions_cubit/get_transactions_event.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';

class TransactionsFilterSheet extends StatefulWidget {
  const TransactionsFilterSheet({super.key});

  @override
  State<TransactionsFilterSheet> createState() =>
      _TransactionsFilterSheetState();
}

class _TransactionsFilterSheetState extends State<TransactionsFilterSheet> {
  String? _selectedClinic;
  String? _selectedSource;
  String? _selectedFromAccount;
  String? _selectedToAccount;
  String? _selectedInvolvedAccount;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final state = context.read<GetTransactionsCubit>().state;
    _selectedClinic = state.clinic;
    _selectedSource = state.source;
    _selectedFromAccount = state.fromAccount;
    _selectedToAccount = state.toAccount;
    _selectedInvolvedAccount = state.accountId;
    _startDate =
        state.startDate != null ? DateTime.tryParse(state.startDate!) : null;
    _endDate = state.endDate != null ? DateTime.tryParse(state.endDate!) : null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          _startDate = picked;
        else
          _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<GetAccountsCubit>()..add(GetAllAccountsEvent(limit: 100)),
        ),
        BlocProvider(
          create: (context) => sl<GetClinicsCubit>()
            ..add(GetAllClinicsEvent(noPagination: true)),
        ),
      ],
      child: BlocBuilder<GetAccountsCubit, GetAccountsState>(
        builder: (context, accountsState) {
          return BlocBuilder<GetClinicsCubit, GetClinicsState>(
            builder: (context, clinicsState) {
              final accounts = accountsState.accounts;
              final clinics = clinicsState.clinics?.clinics ?? [];

              return Container(
                padding: EdgeInsets.fromLTRB(
                    20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
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
                              borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const HeightSpacer(size: 24),
                      Text("Filter Transactions",
                          style: appStyle(
                              context,
                              20,
                              theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              FontWeight.w800)),
                      const HeightSpacer(size: 24),
                      DropdownItem(
                        label: "Clinic",
                        border: Colors.grey.shade300,
                        radius: 15,
                        items: clinics,
                        selectedValue: clinics
                            .where((c) => c.id == _selectedClinic)
                            .firstOrNull
                            ?.name,
                        hintText: "Select clinic",
                        itemAsString: (item) => (item as dynamic).name,
                        onItemSelected: (item) => setState(
                            () => _selectedClinic = (item as dynamic).id),
                        isShadow: false,
                        isLoading: clinicsState.isLoading,
                      ),
                      const HeightSpacer(size: 16),
                      DropdownItem(
                        label: "Source",
                        border: Colors.grey.shade300,
                        radius: 15,
                        items: const ["all", "manual", "appointment", "order"],
                        selectedValue: _selectedSource ?? "all",
                        hintText: "Select source",
                        itemAsString: (item) => (item as String).toUpperCase(),
                        onItemSelected: (item) =>
                            setState(() => _selectedSource = item as String),
                        isShadow: false,
                        isLoading: false,
                      ),
                      const HeightSpacer(size: 16),
                      DropdownItem(
                        label: "Involved Account (Any)",
                        border: Colors.grey.shade300,
                        radius: 15,
                        items: accounts,
                        selectedValue: accounts
                            .where((a) => a.id == _selectedInvolvedAccount)
                            .firstOrNull
                            ?.name,
                        hintText: "Select account",
                        itemAsString: (item) => (item as Account).name ?? "",
                        onItemSelected: (item) => setState(() =>
                            _selectedInvolvedAccount = (item as Account).id),
                        isShadow: false,
                        isLoading:
                            accountsState.status == GetAccountsStatus.loading,
                      ),
                      const HeightSpacer(size: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownItem(
                              label: "From Account",
                              border: Colors.grey.shade300,
                              radius: 15,
                              items: accounts,
                              selectedValue: accounts
                                  .where((a) => a.id == _selectedFromAccount)
                                  .firstOrNull
                                  ?.name,
                              hintText: "Select source",
                              itemAsString: (item) =>
                                  (item as Account).name ?? "",
                              onItemSelected: (item) => setState(() =>
                                  _selectedFromAccount = (item as Account).id),
                              isShadow: false,
                              isLoading: accountsState.status ==
                                  GetAccountsStatus.loading,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownItem(
                              label: "To Account",
                              border: Colors.grey.shade300,
                              radius: 15,
                              items: accounts,
                              selectedValue: accounts
                                  .where((a) => a.id == _selectedToAccount)
                                  .firstOrNull
                                  ?.name,
                              hintText: "Select dest",
                              itemAsString: (item) =>
                                  (item as Account).name ?? "",
                              onItemSelected: (item) => setState(() =>
                                  _selectedToAccount = (item as Account).id),
                              isShadow: false,
                              isLoading: accountsState.status ==
                                  GetAccountsStatus.loading,
                            ),
                          ),
                        ],
                      ),
                      const HeightSpacer(size: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Start Date",
                                        style: appStyle(context, 12,
                                            Colors.grey, FontWeight.w500)),
                                    Text(
                                        _startDate == null
                                            ? "Select"
                                            : DateFormat('dd/MM/yy')
                                                .format(_startDate!),
                                        style: appStyle(
                                            context,
                                            14,
                                            theme.brightness == Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                            FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("End Date",
                                        style: appStyle(context, 12,
                                            Colors.grey, FontWeight.w500)),
                                    Text(
                                        _endDate == null
                                            ? "Select"
                                            : DateFormat('dd/MM/yy')
                                                .format(_endDate!),
                                        style: appStyle(
                                            context,
                                            14,
                                            theme.brightness == Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                            FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const HeightSpacer(size: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context
                                    .read<GetTransactionsCubit>()
                                    .add(ResetTransactionFilters());
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 55),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              child: Text("Reset",
                                  style: appStyle(context, 16,
                                      theme.primaryColor, FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final currentState =
                                    context.read<GetTransactionsCubit>().state;
                                context
                                    .read<GetTransactionsCubit>()
                                    .add(GetAllTransactionsEvent(
                                      search: currentState.search,
                                      clinic: _selectedClinic,
                                      direction: currentState.direction,
                                      source: _selectedSource == "all"
                                          ? null
                                          : _selectedSource,
                                      accountId: _selectedInvolvedAccount,
                                      fromAccount: _selectedFromAccount,
                                      toAccount: _selectedToAccount,
                                      startDate: _startDate?.toIso8601String(),
                                      endDate: _endDate?.toIso8601String(),
                                    ));
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                minimumSize: const Size(0, 55),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                elevation: 0,
                              ),
                              child: Text("Apply",
                                  style: appStyle(context, 16, Colors.white,
                                      FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
