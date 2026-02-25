part of 'appointment_cubit.dart';

enum AppointmentStatus {
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

extension AppointmentStatusX on AppointmentState {
  bool get isInitial => status == AppointmentStatus.initial;
  bool get isLoading => status == AppointmentStatus.loading;
  bool get isSuccess => status == AppointmentStatus.success;
  bool get isError => status == AppointmentStatus.error;
  bool get noConnection => status == AppointmentStatus.noConnection;
  bool get isEditLoading => status == AppointmentStatus.editLoading;
  bool get isEditSuccess => status == AppointmentStatus.editSuccess;
}

@immutable
class AppointmentState {
  final AppointmentStatus status;
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
    this.status = AppointmentStatus.initial,
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
    AppointmentStatus? status,
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
