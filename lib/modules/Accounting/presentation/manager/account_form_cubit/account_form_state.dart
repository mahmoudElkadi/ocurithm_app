import '../../../data/models/account_model.dart';

enum AccountFormStatus { initial, loading, success, failure }

class AccountFormState {
  final AccountFormStatus status;
  final List<OwnerOption> ownerOptions;
  final String? errorMessage;
  
  // Form Values
  final String? selectedClinicId;
  final String? selectedAccountType;
  final String? selectedOwnerId;
  final bool isSuperAdmin;

  AccountFormState({
    required this.status,
    this.ownerOptions = const [],
    this.errorMessage,
    this.selectedClinicId,
    this.selectedAccountType,
    this.selectedOwnerId,
    this.isSuperAdmin = false,
  });

  factory AccountFormState.initial(bool isSuperAdmin) {
    return AccountFormState(
      status: AccountFormStatus.initial,
      isSuperAdmin: isSuperAdmin,
    );
  }

  AccountFormState copyWith({
    AccountFormStatus? status,
    List<OwnerOption>? ownerOptions,
    String? errorMessage,
    String? selectedClinicId,
    String? selectedAccountType,
    String? selectedOwnerId,
    bool? isSuperAdmin,
  }) {
    return AccountFormState(
      status: status ?? this.status,
      ownerOptions: ownerOptions ?? this.ownerOptions,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedClinicId: selectedClinicId ?? this.selectedClinicId,
      selectedAccountType: selectedAccountType ?? this.selectedAccountType,
      selectedOwnerId: selectedOwnerId ?? this.selectedOwnerId,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
    );
  }

  bool get isOwnerEnabled => selectedAccountType != null && 
      selectedAccountType != 'other' &&
      (!isSuperAdmin || selectedClinicId != null);
}
