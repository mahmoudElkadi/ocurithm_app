import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/capability_keys.dart';
import 'package:ocurithm/core/widgets/manage_capabilities.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Product/presentation/manager/get_products_cubit/get_products_cubit.dart';
import 'package:ocurithm/modules/Product/presentation/manager/product_actions_cubit/product_actions_cubit.dart';
import 'package:ocurithm/modules/Product/presentation/views/widgets/product_form_bottom_sheet.dart';
import 'package:ocurithm/modules/Product/presentation/views/widgets/product_view_body.dart';
import '../../../../core/utils/services_locator.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<GetProductsCubit>()..add(GetAllProductsEvent()),
        ),
        BlocProvider(
          create: (context) => sl<ProductActionsCubit>(),
        ),
      ],
      child: BlocBuilder<GetProductsCubit, GetProductsState>(
        builder: (context, state) {
          return CustomScaffold(
            title: "Products",
            actions: [
              manageCapability(
                capability: CapabilityKeys.manageProducts,
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(
                              value: context.read<ProductActionsCubit>()),
                          BlocProvider.value(
                              value: context.read<GetProductsCubit>()),
                        ],
                        child: const ProductFormBottomSheet(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle, size: 28),
                ),
              ),
            ],
            body: state.noConnection
                ? NoInternet(
                    onPressed: () {
                      context.read<GetProductsCubit>().add(GetAllProductsEvent());
                    },
                  )
                : CustomMaterialIndicator(
                    onRefresh: () async {
                      context
                          .read<GetProductsCubit>()
                          .add(ResetProductFilters());
                    },
                    indicatorBuilder:
                        (BuildContext context, IndicatorController controller) {
                      return const Image(
                          image: AssetImage("assets/icons/logo.png"));
                    },
                    child: const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: ProductViewBody(),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
