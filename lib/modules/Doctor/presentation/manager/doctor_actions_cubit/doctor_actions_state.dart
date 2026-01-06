part of 'doctor_actions_cubit.dart';

enum DoctorActionsStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
}

enum DoctorActionType {
  add,
  update,
  delete,
}

extension DoctorActionsStatusX on DoctorActionsState {
  bool get isInitial => state == DoctorActionsStatus.initial;

  bool get isLoading => state == DoctorActionsStatus.loading;

  bool get isSuccess => state == DoctorActionsStatus.success;

  bool get isError => state == DoctorActionsStatus.error;

  bool get noConnection => state == DoctorActionsStatus.noConnection;
}

@immutable
class DoctorActionsState {
  final DoctorActionsStatus state;
  final DoctorActionType? actionType;
  final String? errorMessage;
  final String? successMessage;
  final Doctor? doctor;

  const DoctorActionsState({
    this.state = DoctorActionsStatus.initial,
    this.actionType,
    this.errorMessage,
    this.successMessage,
    this.doctor,
  });

  DoctorActionsState copyWith({
    DoctorActionsStatus? state,
    DoctorActionType? actionType,
    String? errorMessage,
    String? successMessage,
    Doctor? doctor,
  }) {
    return DoctorActionsState(
      state: state ?? this.state,
      actionType: actionType ?? this.actionType,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      doctor: doctor ?? this.doctor,
    );
  }
}
