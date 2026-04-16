import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/supplier_model.dart';
import '../../../data/repos/supplier_repo.dart';

part 'supplier_actions_event.dart';
part 'supplier_actions_state.dart';

class SupplierActionsCubit extends Bloc<SupplierActionsEvent, SupplierActionsState> {
  final SupplierRepo _supplierRepo;

  SupplierActionsCubit(this._supplierRepo) : super(const SupplierActionsState()) {
    on<CreateSupplierEvent>(_onCreateSupplier);
    on<UpdateSupplierEvent>(_onUpdateSupplier);
    on<DeleteSupplierEvent>(_onDeleteSupplier);
  }

  Future<void> _onCreateSupplier(
      CreateSupplierEvent event, Emitter<SupplierActionsState> emit) async {
    emit(state.copyWith(status: SupplierActionsStatus.loading, actingId: null));
    try {
      final supplier = await _supplierRepo.createSupplier(
        name: event.name,
        phoneNumber: event.phoneNumber,
        description: event.description,
        clinic: event.clinic,
        isActive: event.isActive,
      );
      emit(state.copyWith(
        status: SupplierActionsStatus.success,
        successMessage: 'Supplier created successfully',
        supplier: supplier,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SupplierActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateSupplier(
      UpdateSupplierEvent event, Emitter<SupplierActionsState> emit) async {
    emit(state.copyWith(status: SupplierActionsStatus.loading, actingId: event.id));
    try {
      final supplier = await _supplierRepo.updateSupplier(
        event.id,
        name: event.name,
        phoneNumber: event.phoneNumber,
        description: event.description,
        isActive: event.isActive,
      );
      emit(state.copyWith(
        status: SupplierActionsStatus.success,
        successMessage: 'Supplier updated successfully',
        supplier: supplier,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SupplierActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteSupplier(
      DeleteSupplierEvent event, Emitter<SupplierActionsState> emit) async {
    emit(state.copyWith(status: SupplierActionsStatus.loading, actingId: event.id));
    try {
      await _supplierRepo.deleteSupplier(event.id);
      emit(state.copyWith(
        status: SupplierActionsStatus.success,
        successMessage: 'Supplier deleted successfully',
        actingId: event.id,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SupplierActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
