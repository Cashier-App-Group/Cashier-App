import 'package:cashier/app/modules/cashier/views/cashier_view.dart';
import 'package:cashier/app/modules/cashier_member/views/cashier_member_view.dart';
import 'package:cashier/app/modules/discount/views/discount_view.dart';
import 'package:cashier/app/modules/drawer/controllers/drawer_controller.dart';
import 'package:cashier/app/modules/event/controllers/event_controller.dart';
import 'package:cashier/app/modules/history/views/history_view.dart';
import 'package:cashier/app/modules/income/views/income_view.dart';
import 'package:cashier/app/modules/stock/views/Stock_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EventControlPage extends StatelessWidget {
  final EventController themeController = Get.put(EventController());
  final MyDrawerController drawerController = Get.put(MyDrawerController());
  final GlobalKey<ScaffoldState> _eventScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _eventScaffoldKey,
      appBar: AppBar(
        title: const Text('Theme Control'),
        backgroundColor: themeController.isKemerdekaanTheme.value
            ? Color(0xFFe6292f)
            : themeController.isIdulFitriTheme.value
                ? Color(0xFF308c1d)
                : Color(0xFFCD2B21),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Obx(() => Container(
                    color: themeController.isKemerdekaanTheme.value
                        ? Color(0xFFe6292f)
                        : themeController.isIdulFitriTheme.value
                            ? Color(0xFF308c1d)
                            : Color(0xFFCD2B21),
                    padding: EdgeInsets.only(left: 16.0, top: 30.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            drawerController.userName.value.toUpperCase(),
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                          Text(
                            drawerController.userEmail.value,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )),
            ),
            Obx(() {
              if (drawerController.userEmail.value.toLowerCase() ==
                  'admin@gmail.com') {
                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        drawerController.closeDrawer();
                        Get.to(() => CashierView());
                      },
                      title: const Text('Cashier'),
                    ),
                    ListTile(
                      onTap: () {
                        drawerController.closeDrawer();
                        Get.to(() => CashierListView());
                      },
                      title: const Text('Tambah Kasir'),
                    ),
                    ListTile(
                      onTap: () {
                        drawerController.closeDrawer;
                        Get.to(() => DatePage());
                      },
                      title: const Text('Laporan Stok'),
                    ),
                    ListTile(
                      onTap: () {
                        drawerController.closeDrawer();
                        Get.to(() => HistoryView());
                      },
                      title: const Text('Riwayat Pembelian'),
                    ),
                    ListTile(
                      onTap: () {
                        drawerController.closeDrawer();
                        Get.to(() => PemasukanPerHariView());
                      },
                      title: const Text('Pemasukan Harian'),
                    ),
                    ListTile(
                      onTap: () {
                        drawerController.closeDrawer();
                        Get.to(() => DiscountPage());
                      },
                      title: const Text('Diskon'),
                    ),
                    ListTile(
                      onTap: () {
                        drawerController.closeDrawer();
                        Get.to(() => EventControlPage());
                      },
                      title: const Text('Theme'),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            }),
            ListTile(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                drawerController.userEmail.value = '';
                drawerController.update();
                Get.offAllNamed('/login');
              },
              title: const Text('Logout'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => SwitchListTile(
                title: const Text('Tema Idul Fitri'),
                value: themeController.isIdulFitriTheme.value,
                onChanged: (value) {
                  themeController.toggleIdulFitriTheme(value);
                },
              ),
            ),
            Obx(
              () => SwitchListTile(
                title: const Text('Tema Kemerdekaan'),
                value: themeController.isKemerdekaanTheme.value,
                onChanged: (value) {
                  themeController.toggleKemerdekaanTheme(value);
                },
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
