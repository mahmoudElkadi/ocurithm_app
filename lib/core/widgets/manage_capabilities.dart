import 'package:flutter/material.dart';

import '../Network/shared.dart';

class manageCapability extends StatelessWidget {
  const manageCapability({super.key, required this.capability, required this.child});
  final String capability;
  final Widget child;



  @override
  Widget build(BuildContext context) {
   if(CacheHelper.getStringList(key: "capabilities").contains(capability) || CacheHelper.getStringList(key: "capabilities").contains("manageCapability") ){
     return child;
   }else{
     return const SizedBox.shrink();
   }
  }
}
