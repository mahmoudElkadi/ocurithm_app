import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/doctor_repo.dart';

part 'doctor_branch_actions_event.dart';
part 'doctor_branch_actions_state.dart';

/// Cubit for handling doctor branch actions (add, edit, delete)
/// Follows the same pattern as DoctorActionsCubit
class DoctorBranchActionsCubit
    extends Bloc<DoctorBranchActionsEvent, DoctorBranchActionsState> {
  final DoctorRepo doctorRepo;

  DoctorBranchActionsCubit(this.doctorRepo)
      : super(const DoctorBranchActionsState()) {
    on<AddDoctorBranchEvent>(_onAddBranch);
    on<EditDoctorBranchEvent>(_onEditBranch);
    on<DeleteDoctorBranchEvent>(_onDeleteBranch);
  }

  /// Handle add branch
  Future<void> _onAddBranch(
    AddDoctorBranchEvent event,
    Emitter<DoctorBranchActionsState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      isSuccess: false,
      isError: false,
      errorMessage: null,
    ));

    try {
      await doctorRepo.addBranch(
        doctorId: event.doctorId,
        branchId: event.branchId,
        availableFrom: event.availableFrom,
        availableTo: event.availableTo,
        availableDays: event.availableDays,
      );

      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        isError: false,
        successMessage: 'Branch added successfully',
        actionType: BranchActionType.add,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        isError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Handle edit branch
  Future<void> _onEditBranch(
    EditDoctorBranchEvent event,
    Emitter<DoctorBranchActionsState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      isSuccess: false,
      isError: false,
      errorMessage: null,
    ));

    try {
      await doctorRepo.editBranch(
        doctorId: event.doctorId,
        branchId: event.branchId,
        availableFrom: event.availableFrom,
        availableTo: event.availableTo,
        availableDays: event.availableDays,
      );

      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        isError: false,
        successMessage: 'Branch updated successfully',
        actionType: BranchActionType.edit,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        isError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Handle delete branch
  Future<void> _onDeleteBranch(
    DeleteDoctorBranchEvent event,
    Emitter<DoctorBranchActionsState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      isSuccess: false,
      isError: false,
      errorMessage: null,
    ));

    try {
      await doctorRepo.deleteBranch(
        doctorId: event.doctorId,
        branchId: event.branchId,
      );

      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        isError: false,
        successMessage: 'Branch deleted successfully',
        actionType: BranchActionType.delete,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        isError: true,
        errorMessage: e.toString(),
      ));
    }
  }
}
