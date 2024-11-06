import 'package:get/get.dart';

import '../controllers/cashier_controller.dart';

class CashierBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashierController>(
      () => CashierController(),
    );
  }
}
