import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';
import 'package:ocurithm/core/utils/capability_services.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';
import 'package:ocurithm/modules/Product/data/models/product_model.dart';
import 'package:ocurithm/modules/Product/presentation/manager/get_single_product_cubit/get_single_product_cubit.dart';
import 'package:ocurithm/modules/Product/presentation/manager/product_actions_cubit/product_actions_cubit.dart';
import 'package:ocurithm/modules/Product/presentation/views/widgets/product_form_bottom_sheet.dart';

import '../../../../core/utils/services_locator.dart';
import '../manager/get_products_cubit/get_products_cubit.dart';

class ProductDetailsView extends StatefulWidget {
  final String productId;

  const ProductDetailsView({super.key, required this.productId});

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  late GetSingleProductCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<GetSingleProductCubit>();
    _cubit.add(GetProductByIdEvent(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: BlocBuilder<GetSingleProductCubit, GetSingleProductState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.isError) {
              return Center(
                  child: Text(state.errorMessage ?? "Error occurred"));
            } else if (state.product == null) {
              return const Center(child: Text("Product not found"));
            }

            final product = state.product!;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: product.image != null
                        ? Image.network(product.image!, fit: BoxFit.cover)
                        : Container(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            child: Icon(Icons.inventory_2,
                                size: 100, color: theme.primaryColor),
                          ),
                  ),
                  actions: [
                    if (CapabilityServices.hasCapability(
                        CapabilityKeys.manageProducts))
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showEditBottomSheet(context, product),
                      ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.name ?? "",
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              "${product.price ?? 0}\$",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const HeightSpacer(size: 10),
                        Row(
                          children: [
                            if (product.sku != null) ...[
                              _buildBadge(
                                  context, "SKU: ${product.sku}", Colors.blue),
                              const WidthSpacer(size: 10),
                            ],
                            if (product.subCategory != null)
                              _buildBadge(context, product.subCategory!.name!,
                                  Colors.orange),
                          ],
                        ),
                        const HeightSpacer(size: 25),
                        Text(
                          "Description",
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const HeightSpacer(size: 10),
                        Text(
                          product.description ?? "No description provided.",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                            height: 1.5,
                          ),
                        ),
                        const HeightSpacer(size: 30),
                        _buildInfoCard(
                          context,
                          title: "Inventory Details",
                          items: [
                            _InfoItem(
                                label: "Current Stock",
                                value: "${product.stock ?? 0} units"),
                            _InfoItem(
                                label: "Status",
                                value: (product.isActive ?? true)
                                    ? "Active"
                                    : "Inactive",
                                valueColor: (product.isActive ?? true)
                                    ? Colors.green
                                    : Colors.red),
                          ],
                        ),
                        const HeightSpacer(size: 20),
                        _buildInfoCard(
                          context,
                          title: "Clinic Information",
                          items: [
                            _InfoItem(
                                label: "Clinic",
                                value: product.clinic?.name ?? "N/A"),
                            _InfoItem(
                                label: "Last Updated",
                                value: product.updatedAt != null
                                    ? _formatDate(product.updatedAt!)
                                    : "N/A"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title, required List<_InfoItem> items}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.label, style: theme.textTheme.bodyMedium),
                    Text(item.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: item.valueColor,
                        )),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _showEditBottomSheet(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ProductActionsCubit>()),
          BlocProvider.value(value: context.read<GetProductsCubit>()),
        ],
        child: BlocListener<ProductActionsCubit, ProductActionsState>(
          listener: (context, state) {
            if (state.isSuccess) {
              _cubit
                  .add(GetProductByIdEvent(widget.productId)); // Refresh local
            }
          },
          child: ProductFormBottomSheet(product: product),
        ),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final Color? valueColor;

  _InfoItem({required this.label, required this.value, this.valueColor});
}
