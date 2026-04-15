import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/product_model.dart';
import '../../../data/repos/product_repo.dart';

part 'product_actions_event.dart';
part 'product_actions_state.dart';

class ProductActionsCubit
    extends Bloc<ProductActionsEvent, ProductActionsState> {
  final ProductRepo _productRepo;

  ProductActionsCubit(this._productRepo) : super(const ProductActionsState()) {
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onCreateProduct(
      CreateProductEvent event, Emitter<ProductActionsState> emit) async {
    emit(state.copyWith(status: ProductActionsStatus.loading, actingId: null));
    try {
      final product = await _productRepo.createProduct(
        name: event.name,
        price: event.price,
        subCategory: event.subCategory,
        clinic: event.clinic,
        description: event.description,
        image: event.image,
        sku: event.sku,
        isActive: event.isActive,
      );
      emit(state.copyWith(
        status: ProductActionsStatus.success,
        successMessage: 'Product created successfully',
        product: product,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateProduct(
      UpdateProductEvent event, Emitter<ProductActionsState> emit) async {
    emit(state.copyWith(status: ProductActionsStatus.loading, actingId: event.id));
    try {
      final product = await _productRepo.updateProduct(
        event.id,
        name: event.name,
        price: event.price,
        subCategory: event.subCategory,
        description: event.description,
        image: event.image,
        sku: event.sku,
        isActive: event.isActive,
      );
      emit(state.copyWith(
        status: ProductActionsStatus.success,
        successMessage: 'Product updated successfully',
        product: product,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteProduct(
      DeleteProductEvent event, Emitter<ProductActionsState> emit) async {
    emit(state.copyWith(status: ProductActionsStatus.loading, actingId: event.id));
    try {
      await _productRepo.deleteProduct(event.id);
      emit(state.copyWith(
        status: ProductActionsStatus.success,
        successMessage: 'Product deleted successfully',
        actingId: event.id, // Keep actingId for the listener to know whom to delete locally
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
