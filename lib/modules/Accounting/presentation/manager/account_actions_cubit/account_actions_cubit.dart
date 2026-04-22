import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/accounts_repo.dart';
import 'account_actions_event.dart';
import 'account_actions_state.dart';

class AccountActionsCubit extends Bloc<AccountActionsEvent, AccountActionsState> {
  final AccountsRepo accountsRepo;

  AccountActionsCubit(this.accountsRepo) : super(AccountActionsState.initial()) {
    on<CreateAccountEvent>(_onCreateAccount);
    on<UpdateAccountEvent>(_onUpdateAccount);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _onCreateAccount(
    CreateAccountEvent event, Emitter<AccountActionsState> emit) async {
    emit(state.copyWith(status: AccountActionsStatus.loading));
    try {
      await accountsRepo.createAccount(
        name: event.name,
        accountType: event.accountType,
        entityId: event.entityId,
        initialBalance: event.initialBalance,
        clinicId: event.clinicId,
      );
      emit(state.copyWith(
        status: AccountActionsStatus.success,
        successMessage: 'Account created successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountActionsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateAccount(
    UpdateAccountEvent event, Emitter<AccountActionsState> emit) async {
    emit(state.copyWith(status: AccountActionsStatus.loading));
    try {
      await accountsRepo.updateAccount(
        event.id,
        name: event.name,
        isActive: event.isActive,
        accountType: event.accountType,
        entityId: event.entityId,
      );
      emit(state.copyWith(
        status: AccountActionsStatus.success,
        successMessage: 'Account updated successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountActionsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event, Emitter<AccountActionsState> emit) async {
    emit(state.copyWith(status: AccountActionsStatus.loading));
    try {
      await accountsRepo.deleteAccount(event.id);
      emit(state.copyWith(
        status: AccountActionsStatus.success,
        successMessage: 'Account deleted successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountActionsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event, Emitter<AccountActionsState> emit) async {
    emit(state.copyWith(status: AccountActionsStatus.loading));
    try {
      await accountsRepo.addTransaction(
        fromAccountId: event.fromAccountId,
        toAccountId: event.toAccountId,
        amount: event.amount,
        source: event.source,
        note: event.note,
        date: event.date,
      );
      emit(state.copyWith(
        status: AccountActionsStatus.success,
        successMessage: 'Transaction added successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountActionsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event, Emitter<AccountActionsState> emit) async {
    emit(state.copyWith(status: AccountActionsStatus.loading));
    try {
      await accountsRepo.updateTransaction(
        event.id,
        fromAccountId: event.fromAccountId,
        toAccountId: event.toAccountId,
        amount: event.amount,
        source: event.source,
        note: event.note,
        date: event.date,
      );
      emit(state.copyWith(
        status: AccountActionsStatus.success,
        successMessage: 'Transaction updated successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountActionsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event, Emitter<AccountActionsState> emit) async {
    emit(state.copyWith(status: AccountActionsStatus.loading));
    try {
      await accountsRepo.deleteTransaction(event.id);
      emit(state.copyWith(
        status: AccountActionsStatus.success,
        successMessage: 'Transaction deleted successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountActionsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
