import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/widgets/manage_capabilities.dart';
import 'package:ocurithm/core/widgets/no_internet.dart';
import 'package:ocurithm/core/widgets/scaffold_style.dart';
import 'package:ocurithm/modules/Supplier/presentation/manager/get_suppliers_cubit/get_suppliers_cubit.dart';
import 'package:ocurithm/modules/Supplier/presentation/manager/supplier_actions_cubit/supplier_actions_cubit.dart';
import 'package:ocurithm/modules/Supplier/presentation/views/widgets/supplier_form_bottom_sheet.dart';
import 'package:ocurithm/modules/Supplier/presentation/views/widgets/supplier_view_body.dart';
import '../../../../core/utils/services_locator.dart';

class SupplierView extends StatelessWidget {
  const SupplierView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<GetSuppliersCubit>()..add(GetAllSuppliersEvent()),
        ),
        BlocProvider(
          create: (context) => sl<SupplierActionsCubit>(),
        ),
      ],
      child: BlocBuilder<GetSuppliersCubit, GetSuppliersState>(
        builder: (context, state) {
          return CustomScaffold(
            title: "Suppliers",
            actions: [
              manageCapability(
                capability: "manageProducts",
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(
                              value: context.read<SupplierActionsCubit>()),
                          BlocProvider.value(
                              value: context.read<GetSuppliersCubit>()),
                        ],
                        child: const SupplierFormBottomSheet(),
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
                      context.read<GetSuppliersCubit>().add(GetAllSuppliersEvent());
                    },
                  )
                : CustomMaterialIndicator(
                    onRefresh: () async {
                      context
                          .read<GetSuppliersCubit>()
                          .add(ResetSupplierFilters());
                    },
                    indicatorBuilder:
                        (BuildContext context, IndicatorController controller) {
                      return const Image(
                          image: AssetImage("assets/icons/logo.png"));
                    },
                    child: const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SupplierViewBody(),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
