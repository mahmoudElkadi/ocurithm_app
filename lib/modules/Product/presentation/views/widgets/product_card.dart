import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/product_model.dart';
import '../../manager/get_products_cubit/get_products_cubit.dart';
import '../../manager/product_actions_cubit/product_actions_cubit.dart';
import '../product_details_view.dart';

class ProductCard extends StatelessWidget {
  final bool isLoading;
  final Product? product;

  const ProductCard({
    super.key,
    required this.isLoading,
    this.product,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: isLoading || product == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (innerContext) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                            value: context.read<GetProductsCubit>()),
                        BlocProvider.value(
                            value: context.read<ProductActionsCubit>()),
                      ],
                      child: ProductDetailsView(productId: product!.id!),
                    ),
                  ),
                );
              },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 15.w),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
            border: isDark
                ? Border.all(color: Colors.white.withValues(alpha: 0.1))
                : null,
          ),
          child: Row(
            children: [
              if (isLoading)
                _buildShimmer(
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white),
                  ),
                )
              else
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    image: product?.image != null
                        ? DecorationImage(
                            image: NetworkImage(product!.image!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: product?.image == null
                      ? Center(
                          child: Text(
                            product?.name?.isNotEmpty == true
                                ? product!.name![0].toUpperCase()
                                : "?",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
              const WidthSpacer(size: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      _buildShimmer(
                        Container(
                          width: 150,
                          height: 20,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product?.name ?? "No Name",
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (product?.price != null)
                            Text(
                              "${product!.price}\$",
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    const HeightSpacer(size: 5),
                    if (isLoading)
                      _buildShimmer(
                        Container(
                          width: 200,
                          height: 15,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product?.description ?? "No Description",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          const HeightSpacer(size: 5),
                          Row(
                            children: [
                              if (product?.sku != null) ...[
                                _buildBadge(context, "SKU: ${product!.sku}",
                                    Colors.blue),
                                const WidthSpacer(size: 8),
                              ],
                              if (product?.subCategory != null)
                                _buildBadge(
                                    context,
                                    product!.subCategory!.name!,
                                    Colors.orange),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (!isLoading)
                BlocBuilder<ProductActionsCubit, ProductActionsState>(
                  builder: (context, state) {
                    if (state.isLoading && state.actingId == product?.id) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    return IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(context),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              context
                  .read<ProductActionsCubit>()
                  .add(DeleteProductEvent(product!.id!));
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }
}
