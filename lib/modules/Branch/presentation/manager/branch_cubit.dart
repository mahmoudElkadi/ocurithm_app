import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/Services/services_api.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';

import '../../data/model/add_branch_model.dart';
import '../../data/model/branches_model.dart';
import '../../data/repos/branch_repo.dart';
import 'branch_state.dart';

class AdminBranchCubit extends Cubit<AdminBranchState> {
  AdminBranchCubit(this.branchRepo) : super(AdminBranchInitial());

  static AdminBranchCubit get(context) => BlocProvider.of(context);
  BranchRepo branchRepo;
  TextEditingController searchController = TextEditingController();

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

        branches?.branches!.add(Branch(
          id: result.id,
          name: result.name,
          code: result.code,
          address: result.address,
          phone: result.phone,
        ));

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
      Navigator.pop(context);

      emit(AdminBranchError());
    }
  }

  updateBranch({required String id, required AddBranchModel addBranchModel, context}) async {
    emit(AdminBranchLoading());
    try {
      final result = await branchRepo.updateBranch(
        addBranchModel: addBranchModel,
        id: id,
      );
      if (result.error == null && (result.name != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "Branch Updated Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);

        final index = branches?.branches?.indexWhere((branch) => branch.id == id);
        if (index != -1) {
          branches?.branches[index!].name = result.name;
          branches?.branches[index!].code = result.code;
          branches?.branches[index!].address = result.address;
          branches?.branches[index!].phone = result.phone;
        }

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
      Navigator.pop(context);

      emit(AdminBranchError());
    }
  }

  deleteBranch({required String id, context}) async {
    emit(AdminBranchLoading());
    try {
      final result = await branchRepo.deleteBranch(
        id: id,
      );
      if (result.error == null && (result.message != null)) {
        Get.snackbar(
          "Success",
          result.message!,
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);

        branches?.branches.removeWhere((branch) => branch.id == id);

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
      Navigator.pop(context);

      emit(AdminBranchError());
    }
  }

  BranchesModel? branches;
  int page = 1;
  getBranches() async {
    branches = null;
    emit(AdminBranchLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(AdminBranchLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(AdminBranchError());
      } else {
        branches = await branchRepo.getAllBranches(page: page, search: searchController.text, clinic: filterByClinic?.id);
        if (branches?.error == null && branches!.branches.isNotEmpty) {
          emit(AdminBranchSuccess());
        } else {
          emit(AdminBranchError());
        }
      }
    } catch (e) {
      emit(AdminBranchError());
    }
  }

  Clinic? filterByClinic;

  ClinicsModel? clinics;
  getClinics() async {
    clinics = null;
    emit(AdminBranchLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(AdminBranchLoading());
    try {
      if (connection == false) {
        emit(AdminBranchError());
      } else {
        clinics = await ServicesApi().getAllClinics(page: page, search: searchController.text);

        if (clinics?.error == null && clinics!.clinics.isNotEmpty) {
          emit(AdminBranchSuccess());
        } else {
          emit(AdminBranchError());
        }
      }
    } catch (e) {
      emit(AdminBranchError());
    }
  }

  AddBranchModel? branch;
  getBranch({required String id}) async {
    branch = null;
    emit(AdminBranchLoading());
    connection = await InternetConnection().hasInternetAccess;
    emit(AdminBranchLoading());
    try {
      if (connection == false) {
        // Get.snackbar(
        //   "Error",
        //   "No Internet Connection",
        //   backgroundColor: Colorz.errorColor,
        //   colorText: Colorz.white,
        //   icon: Icon(Icons.error, color: Colorz.white),
        // );
        emit(AdminBranchError());
      } else {
        branch = await branchRepo.getBranch(id: id);
        if (branch?.error == null) {
          emit(AdminBranchSuccess());
        } else {
          emit(AdminBranchError());
        }
      }
    } catch (e) {
      emit(AdminBranchError());
    }
  }

  bool? connection;
}
