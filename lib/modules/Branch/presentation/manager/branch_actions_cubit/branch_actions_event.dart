part of 'branch_actions_cubit.dart';

@immutable
abstract class BranchActionsEvent {}

class AddBranchEvent extends BranchActionsEvent {
  final AddBranchModel addBranchModel;

  AddBranchEvent(this.addBranchModel);
}

class UpdateBranchEvent extends BranchActionsEvent {
  final String branchId;
  final AddBranchModel addBranchModel;

  UpdateBranchEvent({required this.branchId, required this.addBranchModel});
}

class DeleteBranchEvent extends BranchActionsEvent {
  final String branchId;

  DeleteBranchEvent(this.branchId);
}

class ResetBranchActionsEvent extends BranchActionsEvent {}
