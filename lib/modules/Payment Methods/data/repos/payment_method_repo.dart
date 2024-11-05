import '../model/payment_method_model.dart';

abstract class PaymentMethodRepo {
  Future<PaymentMethodsModel> getAllPaymentMethods({int? page, String? search});
  Future<PaymentMethod> getPaymentMethod({required String id});
  Future<PaymentMethod> createPaymentMethod({required PaymentMethod paymentMethod});
  Future<PaymentMethod> updatePaymentMethod({required String id, required PaymentMethod paymentMethod});
  Future deletePaymentMethod({required String id});
}
