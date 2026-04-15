part of 'get_single_product_cubit.dart';

abstract class GetSingleProductEvent {
  const GetSingleProductEvent();
}

class GetProductByIdEvent extends GetSingleProductEvent {
  final String id;
  const GetProductByIdEvent(this.id);
}
