abstract class AccountActionsEvent {}

class CreateAccountEvent extends AccountActionsEvent {
  final String name;
  final String accountType;
  final String? entityId;
  final num? initialBalance;
  final String? clinicId;

  CreateAccountEvent({
    required this.name,
    required this.accountType,
    this.entityId,
    this.initialBalance,
    this.clinicId,
  });
}

class UpdateAccountEvent extends AccountActionsEvent {
  final String id;
  final String? name;
  final bool? isActive;
  final String? accountType;
  final String? entityId;

  UpdateAccountEvent({
    required this.id,
    this.name,
    this.isActive,
    this.accountType,
    this.entityId,
  });
}

class DeleteAccountEvent extends AccountActionsEvent {
  final String id;
  DeleteAccountEvent(this.id);
}

class AddTransactionEvent extends AccountActionsEvent {
  final String fromAccountId;
  final String toAccountId;
  final num amount;
  final String? source;
  final String? note;
  final DateTime? date;

  AddTransactionEvent({
    required this.fromAccountId,
    required this.toAccountId,
    required num amount,
    this.source,
    this.note,
    this.date,
  }) : amount = amount;
}

class UpdateTransactionEvent extends AccountActionsEvent {
  final String id;
  final String? fromAccountId;
  final String? toAccountId;
  final num? amount;
  final String? source;
  final String? note;
  final DateTime? date;

  UpdateTransactionEvent({
    required this.id,
    this.fromAccountId,
    this.toAccountId,
    this.amount,
    this.source,
    this.note,
    this.date,
  });
}

class DeleteTransactionEvent extends AccountActionsEvent {
  final String id;
  DeleteTransactionEvent(this.id);
}
