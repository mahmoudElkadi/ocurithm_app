import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/utils/colors.dart';

import '../../data/model/add_branch_model.dart';
import '../../data/repos/branch_repo.dart';
import 'branch_state.dart';

class AdminBranchCubit extends Cubit<AdminBranchState> {
  AdminBranchCubit(this.branchRepo) : super(AdminBranchInitial());

  static AdminBranchCubit get(context) => BlocProvider.of(context);
  BranchRepo branchRepo;
  var branch;

  addBranch({required AddBranchModel addBranchModel, context}) async {
    emit(AdminBranchLoading());
    try {
      final result = await branchRepo.createBranch(
        addBranchModel: addBranchModel,
      );
      if (result.error == null && (result.name != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "Branch Added Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);

        emit(AdminBranchSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(AdminBranchError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(AdminBranchError());
    }
  }
}
