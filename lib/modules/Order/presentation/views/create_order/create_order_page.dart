import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/core/utils/services_locator.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/core/widgets/DropdownPackage.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';
import 'package:ocurithm/modules/Branch/data/model/branches_model.dart';
import 'package:ocurithm/modules/Branch/presentation/manager/get_branches_cubit/get_branches_cubit.dart'
    as branch_cubit;
import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';
import 'package:ocurithm/modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import 'package:ocurithm/modules/Doctor/data/model/doctor_model.dart';
import 'package:ocurithm/modules/Doctor/presentation/manager/get_doctors_cubit/get_doctors_cubit.dart'
    as doctor_cubit;
import 'package:ocurithm/modules/Login/data/model/login_response.dart';
import 'package:ocurithm/modules/Order/data/models/order_model.dart';
import 'package:ocurithm/modules/Order/data/repos/order_repo.dart';
import 'package:ocurithm/modules/Order/presentation/manager/order_actions_cubit/order_actions_bloc.dart';
import 'package:ocurithm/modules/Product/data/models/product_model.dart';

class CreateOrderPage extends StatefulWidget {
  final Order? orderToEdit;

  const CreateOrderPage({super.key, this.orderToEdit});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  String? _selectedClinicId;
  String? _selectedBranchId;
  String? _selectedDoctorId;
  final List<CreateOrderItemUI> _items = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = CacheHelper.getUser("user");

    if (widget.orderToEdit != null) {
      _selectedClinicId = widget.orderToEdit!.clinic?.id;
      _selectedBranchId = widget.orderToEdit!.branch?.id;
      _selectedDoctorId = widget.orderToEdit!.doctor?.id;
      for (var item in widget.orderToEdit!.items) {
        _items.add(CreateOrderItemUI(
          product: Product(
            id: item.productId,
            name: item.productName,
            sku: item.productSku,
            price: item.productPrice,
          ),
          qty: item.quantity?.toInt() ?? 1,
        )..priceController.text = item.productPrice?.toString() ?? "");
      }
    } else {
      _items.add(CreateOrderItemUI());

      // Handle scope initialization
      if (user != null && !user.capabilities.contains("manageCapability")) {
        _selectedClinicId = user.clinic?.id;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = CacheHelper.getUser("user");

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<OrderActionsBloc>()),
        BlocProvider(
            create: (context) => sl<GetClinicsCubit>()
              ..add(GetAllClinicsEvent(noPagination: true))),
        BlocProvider(create: (context) {
          final cubit = sl<branch_cubit.GetBranchesCubit>();
          if (_selectedClinicId != null) {
            cubit.add(branch_cubit.SetClinicFilterEvent(_selectedClinicId));
          }
          return cubit;
        }),
        BlocProvider(create: (context) {
          final cubit = sl<doctor_cubit.GetDoctorsCubit>();
          if (_selectedClinicId != null) {
            cubit.add(doctor_cubit.SetClinicFilterEvent(_selectedClinicId));
          }
          return cubit;
        }),
      ],
      child: BlocListener<OrderActionsBloc, OrderActionsState>(
        listener: (context, state) {
          if (state.status == OrderActionsStatus.success) {
            Navigator.pop(context, true);
          } else if (state.status == OrderActionsStatus.error) {
            SnackbarService.showError(context,
                message: state.errorMessage ?? "Error occurred");
            setState(() => _isSubmitting = false);
          }
        },
        child: Builder(builder: (context) {
          return CustomScaffold(
            title: widget.orderToEdit != null ? "Edit Order" : "Create Order",
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colorz.primaryColor),
              onPressed: () => Navigator.pop(context),
            ),
            body: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  if (user != null &&
                      user.capabilities.contains("manageCapability")) ...[
                    _buildClinicSelector(context),
                    const HeightSpacer(size: 15),
                  ],
                  _buildBranchSelector(context, user),
                  const HeightSpacer(size: 15),
                  _buildDoctorSelector(context, user),
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

  Widget _buildClinicSelector(BuildContext context) {
    return BlocBuilder<GetClinicsCubit, GetClinicsState>(
      builder: (context, state) {
        return DropdownItem<Clinic>(
          items: state.clinics?.clinics ?? [],
          hintText: "Select Clinic",
          itemAsString: (item) => item.name ?? "N/A",
          onItemSelected: (item) {
            setState(() {
              _selectedClinicId = item.id;
              _selectedBranchId = null; // Reset branch
              _selectedDoctorId = null; // Reset doctor
            });
            context
                .read<branch_cubit.GetBranchesCubit>()
                .add(branch_cubit.SetClinicFilterEvent(item.id));
            context
                .read<doctor_cubit.GetDoctorsCubit>()
                .add(doctor_cubit.SetClinicFilterEvent(item.id));
          },
          selectedValue: state.clinics?.clinics
              .where((c) => c.id == _selectedClinicId)
              .firstOrNull
              ?.name,
          isLoading: state.isLoading,
        );
      },
    );
  }

  Widget _buildBranchSelector(BuildContext context, User? user) {
    return BlocBuilder<branch_cubit.GetBranchesCubit,
        branch_cubit.GetBranchesState>(
      builder: (context, state) {
        return DropdownItem<Branch>(
          items: state.branches?.branches ?? [],
          hintText: "Select Branch",
          itemAsString: (item) => item.name ?? "N/A",
          onItemSelected: (item) {
            setState(() {
              _selectedBranchId = item.id;
              _selectedDoctorId = null; // Reset doctor
            });
            context
                .read<doctor_cubit.GetDoctorsCubit>()
                .add(doctor_cubit.SetBranchFilterEvent(item.id));
          },
          selectedValue: state.branches?.branches
              .where((b) => b.id == _selectedBranchId)
              .firstOrNull
              ?.name,
          isLoading: state.state == branch_cubit.GetBranchesStatus.loading,
        );
      },
    );
  }

  Widget _buildDoctorSelector(BuildContext context, User? user) {
    if (user?.userType == "doctor") {
      _selectedDoctorId = user?.id;
      return DropdownItem<Doctor>(
        items: const [],
        hintText: user?.name ?? "Doctor",
        itemAsString: (item) => "",
        onItemSelected: (item) {},
        selectedValue: user?.name,
        isLoading: false,
        readOnly: true,
      );
    }

    return BlocBuilder<doctor_cubit.GetDoctorsCubit,
        doctor_cubit.GetDoctorsState>(
      builder: (context, state) {
        return DropdownItem<Doctor>(
          items: state.doctors?.doctors ?? [],
          hintText: _selectedBranchId == null
              ? "Select Branch First"
              : "Select Doctor",
          itemAsString: (item) => item.name ?? "N/A",
          onItemSelected: (item) => setState(() => _selectedDoctorId = item.id),
          selectedValue: state.doctors?.doctors
              .where((d) => d.id == _selectedDoctorId)
              .firstOrNull
              ?.name,
          isLoading: state.state == doctor_cubit.GetDoctorsStatus.loading,
          readOnly: _selectedBranchId == null,
        );
      },
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
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildProductLookup(index),
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
                Expanded(
                  child: TextField(
                    controller: item.qtyController,
                    decoration: const InputDecoration(
                        labelText: "Quantity",
                        isDense: true,
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      item.qty = int.tryParse(v) ?? 1;
                    },
                  ),
                ),
                const WidthSpacer(size: 10),
                Expanded(
                  child: TextField(
                    controller: item.priceController,
                    readOnly: true,
                    decoration: const InputDecoration(
                        labelText: "Price",
                        isDense: true,
                        border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductLookup(int index) {
    final selectedProducts = _items
        .where((item) => item.product != null)
        .map((item) => item.product!)
        .toList();

    return DropdownItem<Product>(
      items: _items[index].lookupResults,
      disabledItems: selectedProducts,
      hintText: "Search Product (Name/SKU)",
      itemAsString: (p) => "${p.name} (${p.sku}) - Stock: ${p.stock}",
      onItemSelected: (p) {
        setState(() {
          _items[index].product = p;
          _items[index].priceController.text = p.price?.toString() ?? "0";
        });
      },
      onChanged: (query) async {
        if (query.length < 2) return;
        final results = await sl<OrderRepo>().getProductLookup(search: query);
        setState(() {
          _items[index].lookupResults = results.products;
        });
      },
      selectedValue: _items[index].product?.name,
      isLoading: false,
    );
  }

  Widget _buildEmptyItemsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_shopping_cart, size: 60, color: Colors.grey),
          const HeightSpacer(size: 10),
          const Text("No items added yet",
              style: TextStyle(color: Colors.grey)),
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
          : Text(widget.orderToEdit != null ? "Update Order" : "Submit Order",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
    );
  }

  void _addItem() {
    setState(() {
      _items.add(CreateOrderItemUI());
    });
  }

  void _submitOrder(BuildContext context) {
    if (_selectedBranchId == null) {
      SnackbarService.showError(context, message: "Please select a branch");
      return;
    }
    if (_selectedDoctorId == null) {
      SnackbarService.showError(context, message: "Please select a doctor");
      return;
    }
    if (_items.isEmpty) {
      SnackbarService.showError(context,
          message: "Please add at least one item");
      return;
    }

    final List<Map<String, dynamic>> itemsList = [];
    for (var item in _items) {
      if (item.product == null) {
        SnackbarService.showError(context,
            message: "Please select products for all lines");
        return;
      }
      final qty = int.tryParse(item.qtyController.text) ?? 0;
      if (qty <= 0) {
        SnackbarService.showError(context,
            message: "Quantity must be greater than 0");
        return;
      }
      itemsList.add({
        "productId": item.product!.id!,
        "quantity": qty,
      });
    }

    setState(() => _isSubmitting = true);
    if (widget.orderToEdit != null) {
      context.read<OrderActionsBloc>().add(UpdateOrderEvent(
            id: widget.orderToEdit!.id!,
            items: itemsList,
            branch: _selectedBranchId,
            doctor: _selectedDoctorId,
            clinic: _selectedClinicId,
          ));
    } else {
      context.read<OrderActionsBloc>().add(CreateOrderEvent(
            items: itemsList,
            branch: _selectedBranchId,
            doctor: _selectedDoctorId,
            clinic: _selectedClinicId,
          ));
    }
  }
}

class CreateOrderItemUI {
  final TextEditingController qtyController;
  final TextEditingController priceController = TextEditingController();
  Product? product;
  int qty;
  List<Product> lookupResults = [];

  CreateOrderItemUI({this.product, this.qty = 1})
      : qtyController = TextEditingController(text: qty.toString());
}
