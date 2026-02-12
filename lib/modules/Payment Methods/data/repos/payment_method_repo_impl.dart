import 'package:dio/dio.dart';
import '../../../../../core/api/api_constants.dart';
import '../../../../../core/api/api_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../Branch/data/model/data.dart';
import '../model/payment_method_model.dart';
import 'payment_method_repo.dart';

class PaymentMethodRepoImpl implements PaymentMethodRepo {
  final ApiHandler _apiHandler = ApiHandler();

  Options _getOptions() {
    final String? token = CacheHelper.getData(key: "token");
    return Options(
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
    );
  }

  @override
  Future<PaymentMethod> createPaymentMethod(
      {required PaymentMethod paymentMethod}) async {
    try {
      final result = await _apiHandler.post<PaymentMethod>(
        ApiConstants.paymentMethods,
        data: paymentMethod.toJson(),
        options: _getOptions(),
        fromJson: (json) => PaymentMethod.fromJson(json),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message ?? "Failed to add PaymentMethod");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PaymentMethodsModel> getAllPaymentMethods(
      {int? page, String? search, String? clinic}) async {
    Map<String, dynamic> query = {
      if (page != null) "page": page,
      if (page != null) 'limit': 10,
      if (search != null && search.isNotEmpty) "search": search,
      if (clinic != null) "clinic": clinic,
    };

    try {
      final result = await _apiHandler.get<PaymentMethodsModel>(
        ApiConstants.paymentMethods,
        queryParameters: query,
        options: _getOptions(),
        fromJson: (json) => PaymentMethodsModel.fromJson(json),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message ?? "Failed fetch PaymentMethods");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PaymentMethod> getPaymentMethod({required String id}) async {
    try {
      final result = await _apiHandler.get<PaymentMethod>(
        "${ApiConstants.paymentMethods}/$id",
        options: _getOptions(),
        fromJson: (json) => PaymentMethod.fromJson(json),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message ?? "Failed fetch PaymentMethods");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PaymentMethod> updatePaymentMethod(
      {required String id, required PaymentMethod paymentMethod}) async {
    try {
      final result = await _apiHandler.put<PaymentMethod>(
        "${ApiConstants.paymentMethods}/$id",
        data: paymentMethod.toJson(),
        options: _getOptions(),
        fromJson: (json) => PaymentMethod.fromJson(json),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message ?? "Failed fetch PaymentMethods");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DataModel> deletePaymentMethod({required String id}) async {
    try {
      final result = await _apiHandler.delete<DataModel>(
        "${ApiConstants.paymentMethods}/$id",
        options: _getOptions(),
        fromJson: (json) => DataModel.fromJson(json),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message ?? "Failed fetch PaymentMethods");
      }
    } catch (e) {
      rethrow;
    }
  }
}
