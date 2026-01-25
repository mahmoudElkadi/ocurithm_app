part of 'scan_actions_cubit.dart';

enum ScanActionsStatus { initial, loading, success, error, noConnection }

@immutable
class ScanActionsState {
  final ScanActionsStatus state;
  final String? errorMessage;
  final String? successMessage;

  const ScanActionsState({
    this.state = ScanActionsStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  ScanActionsState copyWith({
    ScanActionsStatus? state,
    String? errorMessage,
    String? successMessage,
  }) {
    return ScanActionsState(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
