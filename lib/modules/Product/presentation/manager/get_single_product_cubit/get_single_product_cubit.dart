import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/product_model.dart';
import '../../../data/repos/product_repo.dart';

part 'get_single_product_event.dart';
part 'get_single_product_state.dart';

class GetSingleProductCubit
    extends Bloc<GetSingleProductEvent, GetSingleProductState> {
  final ProductRepo _productRepo;

  GetSingleProductCubit(this._productRepo)
      : super(const GetSingleProductState()) {
    on<GetProductByIdEvent>(_onGetProductById);
  }

  Future<void> _onGetProductById(
      GetProductByIdEvent event, Emitter<GetSingleProductState> emit) async {
    emit(state.copyWith(status: GetSingleProductStatus.loading));
    try {
      final product = await _productRepo.getProductById(event.id);
      emit(state.copyWith(
          status: GetSingleProductStatus.success, product: product));
    } catch (e) {
      emit(state.copyWith(
          status: GetSingleProductStatus.error, errorMessage: e.toString()));
    }
  }
}
