part of 'doctor_branch_actions_cubit.dart';

/// Events for Doctor Branch Actions
abstract class DoctorBranchActionsEvent {}

/// Add branch to doctor
class AddDoctorBranchEvent extends DoctorBranchActionsEvent {
  final String doctorId;
  final String branchId;
  final String availableFrom;
  final String availableTo;
  final List<String> availableDays;

  AddDoctorBranchEvent({
    required this.doctorId,
    required this.branchId,
    required this.availableFrom,
    required this.availableTo,
    required this.availableDays,
  });
}

/// Edit doctor branch
class EditDoctorBranchEvent extends DoctorBranchActionsEvent {
  final String doctorId;
  final String branchId;
  final String availableFrom;
  final String availableTo;
  final List<String> availableDays;

  EditDoctorBranchEvent({
    required this.doctorId,
    required this.branchId,
    required this.availableFrom,
    required this.availableTo,
    required this.availableDays,
  });
}

/// Delete doctor branch
class DeleteDoctorBranchEvent extends DoctorBranchActionsEvent {
  final String doctorId;
  final String branchId;

  DeleteDoctorBranchEvent({
    required this.doctorId,
    required this.branchId,
  });
}
