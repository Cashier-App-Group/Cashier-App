import 'package:cashier/app/modules/cashier/controllers/theme_controller.dart';
import 'package:cashier/app/modules/cashier/views/cashier_view.dart';
import 'package:cashier/app/modules/cashier_member/views/cashier_member_view.dart';
import 'package:cashier/app/modules/discount/views/discount_view.dart';
import 'package:cashier/app/modules/drawer/controllers/drawer_controller.dart';
import 'package:cashier/app/modules/history/views/history_view.dart';
import 'package:cashier/app/modules/stock/views/Stock_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashier/app/modules/stok/view/stok_view.dart' as stokView;

class PemasukanPerHariView extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MyDrawerController drawerController = Get.put(MyDrawerController());
  final GlobalKey<ScaffoldState> _incomeScaffoldKey =
      GlobalKey<ScaffoldState>();
  final ThemeController themeController = Get.put(ThemeController());

  Future<Map<String, int>> _getPemasukanPerHari() async {
    Map<String, int> pemasukanPerTanggal = {};
    QuerySnapshot snapshot = await _firestore.collection('history').get();
    for (var doc in snapshot.docs) {
      DateTime timestamp = doc['timestamp'].toDate();
      String tanggal =
          '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
      int total = (doc['total'] as num).toInt();
      if (pemasukanPerTanggal.containsKey(tanggal)) {
        pemasukanPerTanggal[tanggal] = pemasukanPerTanggal[tanggal]! + total;
      } else {
        pemasukanPerTanggal[tanggal] = total;
      }
    }

    List<MapEntry<String, int>> sortedEntries = pemasukanPerTanggal.entries
        .toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Map.fromEntries(sortedEntries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _incomeScaffoldKey,
      appBar: AppBar(
        title: Text('Pemasukan Per Hari'),
        backgroundColor: Color(0xFFCD2B21),
        elevation: 4,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFCD2B21),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 30.0),
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        drawerController.userName.value.toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        drawerController.userEmail.value,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  );
                }),
              ),
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
                      title: Text('Theme'),
                      trailing: Obx(() {
                        return Switch(
                          value: themeController.isDarkMode.value,
                          onChanged: (value) {
                            themeController.toggleTheme(value);
                          },
                        );
                      }),
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
              },
              title: const Text('Logout'),
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _getPemasukanPerHari(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada data pemasukan.'));
          }

          Map<String, int> pemasukanPerTanggal = snapshot.data!;

          return ListView(
            padding: EdgeInsets.symmetric(vertical: 10),
            children: pemasukanPerTanggal.entries.map((entry) {
              String tanggal = entry.key;
              int totalPemasukan = entry.value;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tanggal,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pemasukan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '+ Rp ${totalPemasukan.toString()}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
