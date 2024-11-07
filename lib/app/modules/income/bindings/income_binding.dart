import 'package:get/get.dart';

import '../controllers/income_controller.dart';

class IncomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncomeController>(
      () => IncomeController(),
    );
  }
}
