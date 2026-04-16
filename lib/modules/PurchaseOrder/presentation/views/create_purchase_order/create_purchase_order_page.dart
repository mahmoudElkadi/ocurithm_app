import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Supplier/presentation/manager/get_suppliers_cubit/get_suppliers_cubit.dart';
import 'package:ocurithm/modules/PurchaseOrder/data/models/purchase_order_model.dart';
import 'package:ocurithm/modules/PurchaseOrder/presentation/manager/purchase_order_actions_cubit/purchase_order_actions_cubit.dart';
import 'package:ocurithm/modules/PurchaseOrder/data/repos/purchase_order_repo.dart';
import 'package:ocurithm/modules/Product/data/models/product_model.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';

class CreatePurchaseOrderPage extends StatefulWidget {
  const CreatePurchaseOrderPage({super.key});

  @override
  State<CreatePurchaseOrderPage> createState() => _CreatePurchaseOrderPageState();
}

class _CreatePurchaseOrderPageState extends State<CreatePurchaseOrderPage> {
  String? _selectedSupplierId;
  final List<CreatePurchaseOrderItemUI> _items = [];
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => sl<PurchaseOrderActionsCubit>(),
      child: BlocListener<PurchaseOrderActionsCubit, PurchaseOrderActionsState>(
        listener: (context, state) {
          if (state.isSuccess) {
            Navigator.pop(context, true);
          } else if (state.isError) {
            SnackbarService.showError(context,
                message: state.errorMessage ?? "Error occurred");
            setState(() => _isSubmitting = false);
          }
        },
        child: Builder(builder: (context) {
          return CustomScaffold(
            title: "Create Purchase Order",
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colorz.primaryColor),
              onPressed: () => Navigator.pop(context),
            ),
            body: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  _buildSupplierSelector(),
                  const HeightSpacer(size: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Items",
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Add Item"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const HeightSpacer(size: 10),
                  Expanded(
                    child: _items.isEmpty
                        ? _buildEmptyItemsState(context)
                        : ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder: (context, index) =>
                                const HeightSpacer(size: 10),
                            itemBuilder: (context, index) =>
                                _buildItemCard(index),
                          ),
                  ),
                  const HeightSpacer(size: 20),
                  _buildSubmitButton(context),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSupplierSelector() {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => sl<GetSuppliersCubit>()..add(GetAllSuppliersEvent(activeOnly: true)),
      child: BlocBuilder<GetSuppliersCubit, GetSuppliersState>(
        builder: (context, state) {
          return DropdownItem(
            radius: 15,
            color: theme.cardColor,
            isShadow: false,
            items: state.suppliers?.suppliers ?? [],
            selectedValue: state.suppliers?.suppliers
                .where((s) => s.id == _selectedSupplierId)
                .firstOrNull
                ?.name,
            hintText: "Select Supplier",
            itemAsString: (item) => item.name,
            onItemSelected: (item) => setState(() => _selectedSupplierId = item.id),
            isLoading: state.isLoading,
          );
        },
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final theme = Theme.of(context);
    final item = _items[index];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: item.skuController,
                  decoration: const InputDecoration(
                    hintText: "Enter SKU...",
                    labelText: "Product SKU",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (v) => _lookupProduct(index, v),
                ),
              ),
              item.isSearching
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      onPressed: () =>
                          _lookupProduct(index, item.skuController.text),
                      icon: const Icon(Icons.search),
                      color: theme.primaryColor,
                    ),
              IconButton(
                onPressed: () => setState(() => _items.removeAt(index)),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
          if (item.product != null) ...[
            const HeightSpacer(size: 10),
            Row(
              children: [
                const Icon(Icons.inventory_2, size: 16, color: Colors.grey),
                const WidthSpacer(size: 8),
                Text(item.product!.name!, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const HeightSpacer(size: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: item.qtyController,
                    decoration: const InputDecoration(labelText: "Quantity", isDense: true, border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const WidthSpacer(size: 10),
                Expanded(
                  child: TextField(
                    controller: item.priceController,
                    decoration: const InputDecoration(labelText: "Price", isDense: true, border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ] else if (item.isSearching)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyItemsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_shopping_cart, size: 60, color: Colors.grey),
          const HeightSpacer(size: 10),
          const Text("No items added yet", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: _isSubmitting ? null : () => _submitOrder(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: _isSubmitting
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("Submit Purchase Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  void _addItem() {
    setState(() {
      _items.add(CreatePurchaseOrderItemUI());
    });
  }

  Future<void> _lookupProduct(int index, String sku) async {
    if (sku.isEmpty) return;
    setState(() {
      _items[index].isSearching = true;
      _items[index].product = null;
    });
    try {
      final product = await sl<PurchaseOrderRepo>().lookupProductBySku(sku);
      setState(() {
        _items[index].product = product;
        _items[index].isSearching = false;
        _items[index].priceController.text = product.price?.toString() ?? "";
      });
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, message: "Product with SKU '$sku' not found");
      }
      setState(() {
        _items[index].isSearching = false;
      });
    }
  }

  void _submitOrder(BuildContext context) {
    if (_selectedSupplierId == null) {
      SnackbarService.showError(context, message: "Please select a supplier");
      return;
    }
    if (_items.isEmpty) {
      SnackbarService.showError(context, message: "Please add at least one item");
      return;
    }

    final List<CreatePurchaseOrderItem> poItems = [];
    for (var item in _items) {
      if (item.product == null) {
        SnackbarService.showError(context, message: "Please resolve all SKU lookups");
        return;
      }
      final qty = double.tryParse(item.qtyController.text) ?? 0;
      final price = double.tryParse(item.priceController.text) ?? 0;
      if (qty <= 0) {
        SnackbarService.showError(context, message: "Quantity must be greater than 0 for all items");
        return;
      }
      poItems.add(CreatePurchaseOrderItem(
        productId: item.product!.id!,
        quantity: qty,
        purchasePrice: price,
      ));
    }

    setState(() => _isSubmitting = true);
    context.read<PurchaseOrderActionsCubit>().add(CreatePOEvent(
      CreatePurchaseOrderRequest(supplierId: _selectedSupplierId!, items: poItems)
    ));
  }
}

class CreatePurchaseOrderItemUI {
  final TextEditingController skuController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: "1");
  final TextEditingController priceController = TextEditingController();
  Product? product;
  bool isSearching = false;
}
