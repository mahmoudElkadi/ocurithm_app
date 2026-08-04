part of 'appointment_cubit.dart';

/// UI loading state for this cubit — unrelated to the appointment's own
/// lifecycle status (Scheduled/Arrived/... — see AppointmentLifecycleStatus).
/// Previously named AppointmentStatus, which collided with that concept.
enum AppointmentUiState {
  initial,
  loading,
  success,
  error,
  noConnection,
  editLoading,
  editSuccess,
  editError,
  loadingBranches,
  loadingDoctors
}

extension AppointmentUiStateX on AppointmentState {
  bool get isInitial => status == AppointmentUiState.initial;
  bool get isLoading => status == AppointmentUiState.loading;
  bool get isSuccess => status == AppointmentUiState.success;
  bool get isError => status == AppointmentUiState.error;
  bool get noConnection => status == AppointmentUiState.noConnection;
  bool get isEditLoading => status == AppointmentUiState.editLoading;
  bool get isEditSuccess => status == AppointmentUiState.editSuccess;
}

@immutable
class AppointmentState {
  final AppointmentUiState status;
  final String? errorMessage;
  final DateTime selectedDate;
  final branch.Branch? selectedBranch;
  final Doctor? selectedDoctor;
  final String search;
  final model.AppointmentModel? appointments;
  final Map<String, List<model.Appointment>>? groupedAppointments;
  final branch.BranchesModel? branches;
  final DoctorModel? doctors;
  final String? updatingAppointmentId;
  final String? updatingAction;

  AppointmentState({
    this.status = AppointmentUiState.initial,
    this.errorMessage,
    DateTime? selectedDate,
    this.selectedBranch,
    this.selectedDoctor,
    this.search = '',
    this.appointments,
    this.groupedAppointments,
    this.branches,
    this.doctors,
    this.updatingAppointmentId,
    this.updatingAction,
  }) : selectedDate = selectedDate ?? DateTime.now();

  AppointmentState copyWith({
    AppointmentUiState? status,
    String? errorMessage,
    DateTime? selectedDate,
    Object? selectedBranch = _sentinel,
    Object? selectedDoctor = _sentinel,
    String? search,
    model.AppointmentModel? appointments,
    Map<String, List<model.Appointment>>? groupedAppointments,
    branch.BranchesModel? branches,
    DoctorModel? doctors,
    Object? updatingAppointmentId = _sentinel,
    Object? updatingAction = _sentinel,
  }) {
    return AppointmentState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedBranch: selectedBranch == _sentinel
          ? this.selectedBranch
          : selectedBranch as branch.Branch?,
      selectedDoctor: selectedDoctor == _sentinel
          ? this.selectedDoctor
          : selectedDoctor as Doctor?,
      search: search ?? this.search,
      appointments: appointments ?? this.appointments,
      groupedAppointments: groupedAppointments ?? this.groupedAppointments,
      branches: branches ?? this.branches,
      doctors: doctors ?? this.doctors,
      updatingAppointmentId: updatingAppointmentId == _sentinel
          ? this.updatingAppointmentId
          : updatingAppointmentId as String?,
      updatingAction: updatingAction == _sentinel
          ? this.updatingAction
          : updatingAction as String?,
    );
  }

  static const _sentinel = Object();

  List<model.Appointment> get morningAppointments =>
      groupedAppointments?['morning'] ?? [];

  List<model.Appointment> get afternoonAppointments =>
      groupedAppointments?['afternoon'] ?? [];

  List<model.Appointment> get eveningAppointments =>
      groupedAppointments?['evening'] ?? [];
}
