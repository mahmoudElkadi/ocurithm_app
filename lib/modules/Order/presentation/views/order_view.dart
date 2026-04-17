import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/manage_capabilities.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Order/presentation/manager/get_orders_cubit/get_orders_bloc.dart';
import 'package:ocurithm/modules/Order/presentation/manager/order_actions_cubit/order_actions_bloc.dart';
import 'package:ocurithm/modules/Order/presentation/views/create_order/create_order_page.dart';
import 'package:ocurithm/modules/Order/presentation/views/widgets/order_view_body.dart';
import '../../../../core/utils/services_locator.dart';

class OrderView extends StatelessWidget {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<GetOrdersBloc>()..add(GetAllOrdersEvent()),
        ),
        BlocProvider(
          create: (context) => sl<OrderActionsBloc>(),
        ),
      ],
      child: BlocBuilder<GetOrdersBloc, GetOrdersState>(
        builder: (context, state) {
          return CustomScaffold(
            title: "Orders",
            actions: [
              manageCapability(
                capability: "addOrders",
                child: IconButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateOrderPage(),
                      ),
                    );
                    if (result == true) {
                      context.read<GetOrdersBloc>().add(GetAllOrdersEvent());
                    }
                  },
                  icon: const Icon(Icons.add_circle, size: 28),
                ),
              ),
            ],
            body: state.noConnection
                ? NoInternet(
                    onPressed: () {
                      context.read<GetOrdersBloc>().add(GetAllOrdersEvent());
                    },
                  )
                : CustomMaterialIndicator(
                    onRefresh: () async {
                      context.read<GetOrdersBloc>().add(ResetOrderFilters());
                    },
                    indicatorBuilder:
                        (BuildContext context, IndicatorController controller) {
                      return const Image(
                          image: AssetImage("assets/icons/logo.png"));
                    },
                    child: const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: OrderViewBody(),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
