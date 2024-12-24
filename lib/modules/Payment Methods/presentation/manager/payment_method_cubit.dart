import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/colors.dart';

import '../../../../Services/services_api.dart';
import '../../../Clinics/data/model/clinics_model.dart';
import '../../data/model/payment_method_model.dart';
import '../../data/repos/payment_method_repo.dart';
import 'payment_method_state.dart';

class PaymentMethodCubit extends Cubit<PaymentMethodState> {
  PaymentMethodCubit(this.paymentMethodRepo) : super(PaymentMethodInitial());

  static PaymentMethodCubit get(context) => BlocProvider.of(context);
  PaymentMethodRepo paymentMethodRepo;
  TextEditingController searchController = TextEditingController();

  addPaymentMethod({required PaymentMethod paymentMethod, context}) async {
    emit(PaymentMethodLoading());
    try {
      final result = await paymentMethodRepo.createPaymentMethod(
        paymentMethod: paymentMethod,
      );
      if (result.error == null && (result.title != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "PaymentMethod Added Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);

        paymentMethods?.paymentMethods!.add(PaymentMethod(
          id: result.id,
          title: result.title,
          description: result.description,
        ));

        emit(PaymentMethodSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(PaymentMethodError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(PaymentMethodError());
    }
  }

  ClinicsModel? clinics;
  getClinics() async {
    clinics = null;
    emit(AdminClinicLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(AdminClinicLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(AdminClinicError());
      } else {
        clinics = await ServicesApi().getAllClinics();
        log(clinics.toString());
        if (clinics?.error == null && clinics!.clinics.isNotEmpty) {
          emit(AdminClinicSuccess());
        } else {
          emit(AdminClinicError());
        }
      }
    } catch (e) {
      log(e.toString());
      emit(AdminClinicError());
    }
  }

  updatePaymentMethod({required String id, required PaymentMethod paymentMethod, context}) async {
    emit(PaymentMethodLoading());
    try {
      final result = await paymentMethodRepo.updatePaymentMethod(
        paymentMethod: paymentMethod,
        id: id,
      );
      if (result.error == null && (result.title != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "PaymentMethod Updated Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);

        final index = paymentMethods?.paymentMethods?.indexWhere((paymentMethod) => paymentMethod.id == id);
        if (index != -1) {
          paymentMethods?.paymentMethods?[index!].title = result.title;
          paymentMethods?.paymentMethods?[index!].description = result.description;
        }

        emit(PaymentMethodSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(PaymentMethodError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(PaymentMethodError());
    }
  }

  deletePaymentMethod({required String id, context}) async {
    emit(PaymentMethodLoading());
    try {
      final result = await paymentMethodRepo.deletePaymentMethod(
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

        paymentMethods?.paymentMethods?.removeWhere((paymentMethod) => paymentMethod.id == id);

        emit(PaymentMethodSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(PaymentMethodError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(PaymentMethodError());
    }
  }

  PaymentMethodsModel? paymentMethods;
  int page = 1;
  getPaymentMethods() async {
    paymentMethods = null;
    emit(PaymentMethodLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(PaymentMethodLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(PaymentMethodError());
      } else {
        paymentMethods = await paymentMethodRepo.getAllPaymentMethods(page: page, search: searchController.text);
        if (paymentMethods?.error == null && paymentMethods!.paymentMethods!.isNotEmpty) {
          emit(PaymentMethodSuccess());
        } else {
          emit(PaymentMethodError());
        }
      }
    } catch (e) {
      log(e.toString());
      emit(PaymentMethodError());
    }
  }

  PaymentMethod? paymentMethod;
  getPaymentMethod({required String id}) async {
    paymentMethod = null;
    emit(PaymentMethodLoading());
    connection = await InternetConnection().hasInternetAccess;
    emit(PaymentMethodLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(PaymentMethodError());
      } else {
        paymentMethod = await paymentMethodRepo.getPaymentMethod(id: id);
        if (paymentMethod?.error == null) {
          emit(PaymentMethodSuccess());
        } else {
          emit(PaymentMethodError());
        }
      }
    } catch (e) {
      log(e.toString());
      emit(PaymentMethodError());
    }
  }

  bool? connection;
}
