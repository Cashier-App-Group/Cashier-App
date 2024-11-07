import 'package:cashier/app/modules/cashier/views/cashier_view.dart';
import 'package:cashier/app/modules/drawer/controllers/drawer_controller.dart';
import 'package:cashier/app/modules/history/views/history_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PemasukanPerHariView extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final MyDrawerController drawerController = Get.put(MyDrawerController());
  final GlobalKey<ScaffoldState> _incomeScaffoldKey =
      GlobalKey<ScaffoldState>();

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

    return pemasukanPerTanggal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Pemasukan Per Hari'),
        backgroundColor: Color(0xFFCD2B21),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Obx(() => Container(
                    color: Color(0xFFCD2B21),
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
            ListTile(
              onTap: () {
                drawerController.closeDrawer();
                Get.to(() => CashierView());
              },
              title: const Text('Cashier'),
            ),
            ListTile(
              onTap: drawerController.closeDrawer,
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
              onTap: () async {
                Get.offAllNamed('/login');
              },
              title: const Text('Logout'),
            )
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
            children: pemasukanPerTanggal.entries.map((entry) {
              String tanggal = entry.key;
              int totalPemasukan = entry.value;

              return Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(11),
                      child: Text(
                        tanggal,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 0),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 0.2,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pemasukan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 0),
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
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
