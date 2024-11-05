import 'dart:developer';

import '../../../../../core/Network/dio_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/config.dart';
import '../../../Branch/data/model/data.dart';
import '../model/payment_method_model.dart';
import 'payment_method_repo.dart';

class PaymentMethodRepoImpl implements PaymentMethodRepo {
  @override
  Future<PaymentMethod> createPaymentMethod({required PaymentMethod paymentMethod}) async {
    final url = "${Config.baseUrl}${Config.paymentMethods}";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<PaymentMethod>(
      url: url,
      data: paymentMethod.toJson(),
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => PaymentMethod.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to add PaymentMethod");
    }
  }

  @override
  Future<PaymentMethodsModel> getAllPaymentMethods({int? page, String? search}) async {
    final url = "${Config.baseUrl}${Config.paymentMethods}";
    final String? token = CacheHelper.getData(key: "token");
    log("token: $token");
    Map<String, dynamic> query = {"page": page, 'limit': 10, "search": search};

    final result = await ApiService.request<PaymentMethodsModel>(
      url: url,
      method: 'GET',
      queryParameters: query,
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => PaymentMethodsModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch PaymentMethods");
    }
  }

  @override
  Future<PaymentMethod> getPaymentMethod({required String id}) async {
    final url = "${Config.baseUrl}${Config.paymentMethods}/$id";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<PaymentMethod>(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => PaymentMethod.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch PaymentMethods");
    }
  }

  @override
  Future<PaymentMethod> updatePaymentMethod({required String id, required PaymentMethod paymentMethod}) async {
    final url = "${Config.baseUrl}${Config.paymentMethods}/$id";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<PaymentMethod>(
      url: url,
      method: 'PUT',
      data: paymentMethod.toJson(),
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => PaymentMethod.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch PaymentMethods");
    }
  }

  @override
  Future<DataModel> deletePaymentMethod({required String id}) async {
    final url = "${Config.baseUrl}${Config.paymentMethods}/$id";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<DataModel>(
      url: url,
      method: 'DELETE',
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => DataModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch PaymentMethods");
    }
  }
}
