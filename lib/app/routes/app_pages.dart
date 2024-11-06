import 'package:cashier/app/modules/cashier/bindings/cashier_binding.dart';
import 'package:cashier/app/modules/cashier/views/cashier_view.dart';
import 'package:cashier/app/modules/login/bindings/login_binding.dart';
import 'package:cashier/app/modules/login/views/login_view.dart';
import 'package:cashier/app/modules/register/bindings/register_binding.dart';
import 'package:cashier/app/modules/register/views/register_view.dart';
import 'package:cashier/app/modules/splashscreen/views/splashscreen_view.dart';
import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASHSCREEN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASHSCREEN,
      page: () => SplashscreenView(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.CASHIER,
      page: () => CashierView(),
      binding: CashierBinding(),
    ),
  ];
}
