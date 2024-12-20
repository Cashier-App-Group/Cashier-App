import 'dart:math';
import 'package:cashier/app/modules/cashier/views/cashier_view.dart';
import 'package:cashier/app/modules/event/controllers/event_controller.dart';
import 'package:cashier/app/modules/register/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ReceiptView extends StatelessWidget {
  final String cashierName;
  final List<Map<String, dynamic>> checkoutItems;
  final double total;
  final double payment;
  final double change;
  final EventController themeController = Get.put(EventController());

  ReceiptView({
    Key? key,
    required this.cashierName,
    required this.checkoutItems,
    required this.total,
    required this.payment,
    required this.change,
  }) : super(key: key);

  static Future<String> fetchCashierName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .get();
      return doc.data()?['name'] ?? 'Unknown Cashier';
    }
    return 'Unknown Cashier';
  }

  String generateOrderNumber() {
    final random = Random();
    final orderNumber = random.nextInt(1000).toString().padLeft(3, '0');
    return 'Order #$orderNumber';
  }

  Future<double> getPrice(String foodName) async {
    try {
      var docSnapshot = await FirebaseFirestore.instance
          .collection('menu')
          .where('name', isEqualTo: foodName)
          .limit(1)
          .get();

      if (docSnapshot.docs.isNotEmpty) {
        double price = (docSnapshot.docs.first['price'] ?? 0).toDouble();
        return price;
      } else {
        return 0.0;
      }
    } catch (e) {
      print('Error fetching price: $e');
      return 0.0;
    }
  }

  void saveReceiptToFirebase() async {
    try {
      String orderNumber = generateOrderNumber();

      List<Map<String, dynamic>> detailedItems = [];

      for (var item in checkoutItems) {
        String name = item['name'] ?? 'Unknown';
        int quantity = item['quantity'] ?? 0;
        double price = await getPrice(name);
        double totalPrice = quantity * price;

        detailedItems.add({
          'name': name,
          'quantity': quantity,
          'price': price,
          'total': totalPrice,
        });
      }

      await FirebaseFirestore.instance.collection('history').add({
        'orderNumber': orderNumber,
        'cashierName': cashierName,
        'checkoutItems': detailedItems,
        'total': total,
        'payment': payment,
        'change': change,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Transaksi berhasil disimpan.');
    } catch (e) {
      print('Error menyimpan transaksi: $e');
    }
  }

  void showPrintedAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nota Sudah Dicetak'),
          content: Text('Nota Anda telah berhasil dicetak.'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.to(() => CashierView());
                  },
                  child: Text('Kembali ke Menu Utama'),
                  style: ElevatedButton.styleFrom(
                      primary: Color(0xFFCD2B21), onPrimary: Colors.white),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nota Pembelian'),
        backgroundColor: themeController.isKemerdekaanTheme.value
            ? Color(0xFFe6292f)
            : themeController.isIdulFitriTheme.value
                ? Color(0xFF308c1d)
                : Color(0xFFCD2B21),
      ),
      body: Center(
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
              Text('Nomor Pembelian: ${generateOrderNumber()}'),
              SizedBox(height: 8),
              ...List.generate(checkoutItems.length, (index) {
                var item = checkoutItems[index];
                String name = item['name'] ?? 'Unknown';
                int quantity = item['quantity'] ?? 0;
                double price = 0.0;

                return FutureBuilder<double>(
                  future: getPrice(name),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error fetching price');
                    } else if (snapshot.hasData) {
                      price = snapshot.data ?? 0.0;
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
                              Text(
                                  'Total: Rp${(totalPrice).toStringAsFixed(2)}'),
                            ],
                          ),
                          Divider(thickness: 1.0, color: Colors.black),
                        ],
                      );
                    } else {
                      return Text('Price not available');
                    }
                  },
                );
              }),
              SizedBox(height: 8),
              Divider(thickness: 1.0, color: Colors.black),
              SizedBox(height: 8),
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
                    saveReceiptToFirebase();
                    showPrintedAlert(context);
                  },
                  child: Text('Cetak Nota'),
                  style: ElevatedButton.styleFrom(
                      primary: themeController.isKemerdekaanTheme.value
                          ? Color(0xFFe6292f) // Kemerdekaan theme color
                          : themeController.isIdulFitriTheme.value
                              ? Color(0xFF308c1d) // Idul Fitri theme color
                              : Color(0xFFCD2B21),
                      onPrimary: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
