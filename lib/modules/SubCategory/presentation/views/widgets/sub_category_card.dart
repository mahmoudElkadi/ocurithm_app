import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ocurithm/core/widgets/height_spacer.dart';
import 'package:ocurithm/core/widgets/width_spacer.dart';
import 'package:shimmer/shimmer.dart';

import 'package:ocurithm/modules/SubCategory/data/models/sub_category_model.dart';
import 'package:ocurithm/modules/SubCategory/presentation/manager/sub_category_actions_cubit/sub_category_actions_cubit.dart';
import 'package:ocurithm/modules/SubCategory/presentation/manager/get_sub_categories_cubit/get_sub_categories_cubit.dart';
import 'package:ocurithm/modules/SubCategory/presentation/views/widgets/sub_category_form_bottom_sheet.dart';

class SubCategoryCard extends StatelessWidget {
  final bool isLoading;
  final SubCategory? subCategory;

  const SubCategoryCard({
    super.key,
    required this.isLoading,
    this.subCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: isDark ? 0.05 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Subtle background accent
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primaryColor.withValues(alpha: 0.03),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Image/Avatar Section
                    _buildImageSection(context, theme, isDark),
                    const WidthSpacer(size: 16),
                    // Info Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isLoading)
                            _buildShimmer(
                              Container(
                                width: 120.w,
                                height: 20.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            )
                          else
                            Text(
                              subCategory?.name ?? "Unnamed",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          const HeightSpacer(size: 6),
                          if (isLoading)
                            _buildShimmer(
                              Container(
                                width: 80.w,
                                height: 16.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                subCategory?.category?.name ?? 'General',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          const HeightSpacer(size: 8),
                          if (isLoading)
                            _buildShimmer(
                              Container(
                                width: 180.w,
                                height: 14.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            )
                          else
                            Text(
                              subCategory?.description ?? "No description available",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white60 : Colors.black54,
                                height: 1.3,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Action Section
                    if (!isLoading)
                      _buildActionMenu(context, theme, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, ThemeData theme, bool isDark) {
    if (isLoading) {
      return _buildShimmer(
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      );
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.1),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: subCategory?.image != null && subCategory!.image!.isNotEmpty
            ? Image.network(
                subCategory!.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(theme),
              )
            : _buildPlaceholder(theme),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Center(
      child: Text(
        subCategory?.name?.isNotEmpty == true ? subCategory!.name![0].toUpperCase() : "?",
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        PopupMenuButton<String>(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.more_vert, size: 20, color: isDark ? Colors.white70 : Colors.grey[600]),
          ),
          onSelected: (value) {
            if (value == 'edit') {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<SubCategoryActionsCubit>()),
                    BlocProvider.value(value: context.read<GetSubCategoriesCubit>()),
                  ],
                  child: SubCategoryFormBottomSheet(subCategory: subCategory),
                ),
              );
            } else if (value == 'delete') {
              _showDeleteConfirmation(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, size: 20),
                  WidthSpacer(size: 12),
                  Text("Edit"),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, size: 20, color: theme.colorScheme.error),
                  const WidthSpacer(size: 12),
                  Text("Delete", style: TextStyle(color: theme.colorScheme.error)),
                ],
              ),
            ),
          ],
        ),
        // Active Status Indicator
        if (subCategory?.isActive == true)
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Delete Sub-Category"),
        content: const Text("Are you sure you want to delete this sub-category?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              context.read<SubCategoryActionsCubit>().add(DeleteSubCategoryEvent(subCategory!.id!));
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
