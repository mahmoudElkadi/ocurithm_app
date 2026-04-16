import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/manage_capabilities.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/PurchaseOrder/presentation/manager/get_purchase_orders_cubit/get_purchase_orders_cubit.dart';
import 'package:ocurithm/modules/PurchaseOrder/presentation/manager/purchase_order_actions_cubit/purchase_order_actions_cubit.dart';
import 'package:ocurithm/modules/PurchaseOrder/presentation/views/create_purchase_order/create_purchase_order_page.dart';
import 'package:ocurithm/modules/PurchaseOrder/presentation/views/widgets/purchase_order_view_body.dart';
import '../../../../core/utils/services_locator.dart';

class PurchaseOrderView extends StatelessWidget {
  const PurchaseOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<GetPurchaseOrdersCubit>()..add(GetAllPurchaseOrdersEvent()),
        ),
        BlocProvider(
          create: (context) => sl<PurchaseOrderActionsCubit>(),
        ),
      ],
      child: BlocBuilder<GetPurchaseOrdersCubit, GetPurchaseOrdersState>(
        builder: (context, state) {
          return CustomScaffold(
            title: "Purchase Orders",
            actions: [
              manageCapability(
                capability: "manageProducts",
                child: IconButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreatePurchaseOrderPage(),
                      ),
                    );
                    if (result == true) {
                      context.read<GetPurchaseOrdersCubit>().add(GetAllPurchaseOrdersEvent());
                    }
                  },
                  icon: const Icon(Icons.add_circle, size: 28),
                ),
              ),
            ],
            body: state.noConnection
                ? NoInternet(
                    onPressed: () {
                      context.read<GetPurchaseOrdersCubit>().add(GetAllPurchaseOrdersEvent());
                    },
                  )
                : CustomMaterialIndicator(
                    onRefresh: () async {
                      context
                          .read<GetPurchaseOrdersCubit>()
                          .add(ResetPOFilters());
                    },
                    indicatorBuilder:
                        (BuildContext context, IndicatorController controller) {
                      return const Image(
                          image: AssetImage("assets/icons/logo.png"));
                    },
                    child: const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: PurchaseOrderViewBody(),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
