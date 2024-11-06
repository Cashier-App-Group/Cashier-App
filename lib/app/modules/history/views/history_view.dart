import 'package:cashier/app/modules/cashier/views/cashier_view.dart';
import 'package:cashier/app/modules/drawer/controllers/drawer_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class HistoryView extends StatelessWidget {
  final MyDrawerController drawerController = Get.put(MyDrawerController());
  final GlobalKey<ScaffoldState> _historyScaffoldKey =
      GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _historyScaffoldKey,
      appBar: AppBar(
        title: Text('Riwayat Pembelian'),
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
              onTap: drawerController.closeDrawer,
              title: const Text('Pemasukan dan Pengeluaran'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('history')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            var historyItems = snapshot.data?.docs ?? [];

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8,
              ),
              itemCount: historyItems.length,
              itemBuilder: (context, index) {
                var history = historyItems[index];
                String orderNumber = history['orderNumber'] ?? 'N/A';
                Timestamp timestamp = history['timestamp'] ?? Timestamp.now();
                double total = history['total']?.toDouble() ?? 0.0;
                DateTime dateTime = timestamp.toDate();
                String formattedDate =
                    '${dateTime.day}-${dateTime.month}-${dateTime.year}';
                String formattedTime = '${dateTime.hour}:${dateTime.minute}';

                return Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$orderNumber',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Tanggal: $formattedDate',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Jam: $formattedTime',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Total: Rp ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HistoryDetailView(
                                  orderNumber: orderNumber,
                                ),
                              ),
                            );
                          },
                          child: Text('Detail'),
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFCD2B21),
                            onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class HistoryDetailView extends StatelessWidget {
  final String orderNumber;

  HistoryDetailView({Key? key, required this.orderNumber}) : super(key: key);

  void showPrintedAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nota Anda telah berhasil dicetak.'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFFCD2B21),
      ),
    );
  }

  Future<Map<String, dynamic>> fetchReceiptData(String orderNumber) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('history')
          .where('orderNumber', isEqualTo: orderNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      } else {
        throw Exception('No data found');
      }
    } catch (e) {
      print('Error fetching receipt data: $e');
      throw Exception('Failed to load receipt data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nota Pembelian'),
        backgroundColor: Color(0xFFCD2B21),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchReceiptData(orderNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found.'));
          } else {
            var receiptData = snapshot.data!;
            var cashierName = receiptData['cashierName'];
            var checkoutItems =
                List<Map<String, dynamic>>.from(receiptData['checkoutItems']);
            var total = receiptData['total'];
            var payment = receiptData['payment'];
            var change = receiptData['change'];

            return Center(
              child: Container(
                width: 300,
                padding: EdgeInsets.all(16.0),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'KAF Chicken',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Desa Tunggulsari',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Divider(thickness: 1.0, color: Colors.black),
                    SizedBox(height: 8),
                    Text('Tanggal: ${DateTime.now()}'),
                    Text('Kasir: $cashierName'),
                    SizedBox(height: 8),
                    Divider(thickness: 1.0, color: Colors.black),
                    SizedBox(height: 8),

                    Text('Nomor Pembelian: $orderNumber'),
                    SizedBox(height: 8),
                    ...List.generate(checkoutItems.length, (index) {
                      var item = checkoutItems[index];
                      String name = item['name'] ?? 'Unknown';
                      int quantity = item['quantity'] ?? 0;
                      double price = item['price'] ?? 0.0;
                      double totalPrice = quantity * price;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$name', style: TextStyle(fontSize: 16)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Jumlah: $quantity'),
                              Text('Harga: Rp${price.toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total: Rp${totalPrice.toStringAsFixed(2)}'),
                            ],
                          ),
                          Divider(thickness: 1.0, color: Colors.black),
                        ],
                      );
                    }),
                    SizedBox(height: 8),
                    Divider(thickness: 1.0, color: Colors.black),
                    SizedBox(height: 8),
                    // Total Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rp${total.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Uang Dibayar'),
                        Text('Rp${payment.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Kembalian'),
                        Text('Rp${change.toStringAsFixed(2)}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Divider(thickness: 1.0, color: Colors.black),
                    Center(
                      child: Text(
                        'Terima Kasih!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          showPrintedAlert(context);
                        },
                        child: Text('Cetak Nota'),
                        style: ElevatedButton.styleFrom(
                            primary: Color(0xFFCD2B21),
                            onPrimary: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
