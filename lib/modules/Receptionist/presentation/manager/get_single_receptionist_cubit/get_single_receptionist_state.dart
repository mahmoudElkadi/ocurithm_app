part of 'get_single_receptionist_cubit.dart';

enum GetSingleReceptionistStatus {
  initial,
  loading,
  success,
  error,
  noConnection
}

extension GetSingleReceptionistStatusX on GetSingleReceptionistState {
  bool get isInitial => state == GetSingleReceptionistStatus.initial;

  bool get isLoading => state == GetSingleReceptionistStatus.loading;

  bool get isSuccess => state == GetSingleReceptionistStatus.success;

  bool get isError => state == GetSingleReceptionistStatus.error;

  bool get noConnection => state == GetSingleReceptionistStatus.noConnection;
}

@immutable
class GetSingleReceptionistState {
  final GetSingleReceptionistStatus state;
  final String? errorMessage;
  final Receptionist? receptionist;

  const GetSingleReceptionistState({
    this.state = GetSingleReceptionistStatus.initial,
    this.errorMessage,
    this.receptionist,
  });

  GetSingleReceptionistState copyWith({
    GetSingleReceptionistStatus? state,
    String? errorMessage,
    Receptionist? receptionist,
  }) {
    return GetSingleReceptionistState(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      receptionist: receptionist ?? this.receptionist,
    );
  }
}
