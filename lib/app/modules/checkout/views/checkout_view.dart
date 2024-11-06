import 'package:cashier/app/modules/cashier/controllers/cashier_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutView extends StatefulWidget {
  @override
  _CheckoutViewState createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final CashierController controller = Get.find<CashierController>();
  final TextEditingController uangDiberikanController = TextEditingController();
  double kembalian = 0.0; // Default value of kembalian

  // Function to fetch price from Firestore based on food name
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

  // Function to calculate total price
  Future<double> calculateTotal() async {
    double total = 0.0;
    for (var item in controller.checkoutItems) {
      String name = item['name'];
      int quantity = item['quantity'];
      double price = await getPrice(name);
      total += price * quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Color(0xFFCD2B21),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Pesanan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Obx(() {
              if (controller.checkoutItems.isEmpty) {
                return Center(child: Text('Tidak ada pesanan.'));
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: controller.checkoutItems.length,
                    itemBuilder: (context, index) {
                      var item = controller.checkoutItems[index];
                      String name = item['name'] ?? 'Unknown';
                      int quantity = item['quantity'] ?? 0;

                      return FutureBuilder<double>(
                        future: getPrice(name),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(); // Loading data
                          } else if (snapshot.hasError) {
                            return Text('Error fetching price');
                          } else if (snapshot.hasData) {
                            double price = snapshot.data ?? 0.0;
                            double totalPrice = quantity * price;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(name,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(height: 8),
                                            Text('Jumlah: $quantity'),
                                            Text(
                                                'Harga per item: Rp ${price.toString()}'),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                              'Rp ${totalPrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider(color: Colors.grey, thickness: 1.0),
                                ],
                              ),
                            );
                          } else {
                            return Text('Price not available');
                          }
                        },
                      );
                    },
                  ),
                );
              }
            }),
            SizedBox(height: 16),
            Obx(() {
              return FutureBuilder<double>(
                future: calculateTotal(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Loading total
                  } else if (snapshot.hasError) {
                    return Text('Error calculating total');
                  } else if (snapshot.hasData) {
                    double total = snapshot.data ?? 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total: Rp ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        // Row containing 'Bayar' label and TextField for uangDiberikan
                        Row(
                          children: [
                            Text(
                              'Bayar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 16),
                            Container(
                              width: 200,
                              height: 50,
                              child: TextField(
                                  controller: uangDiberikanController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    prefixText: 'Rp ',
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  // Hapus setState di sini
                                  onChanged: (value) {
                                    // Di sini hanya memperbarui text input tanpa memanggil setState
                                  },
                                  onEditingComplete: () {
                                    setState(() {
                                      double uangDiberikan = double.tryParse(
                                              uangDiberikanController.text) ??
                                          0.0;

                                      // Hitung total harga pesanan
                                      calculateTotal().then((totalHarga) {
                                        if (uangDiberikan >= totalHarga) {
                                          kembalian =
                                              uangDiberikan - totalHarga;
                                        } else {
                                          kembalian =
                                              0.0; // Reset kembalian jika uang tidak cukup
                                        }
                                        setState(
                                            () {}); // Memastikan UI diperbarui
                                      });
                                    });
                                  }),
                            ),
                            SizedBox(width: 8),
                            // Tanda centang akan selalu muncul
                            Icon(
                              Icons.check,
                              color: Colors.green, // Centang selalu muncul
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kembalian: Rp ${kembalian.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    // Trigger login with the email and password entered
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xFFCD2B21),
                                    onPrimary: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 1.0, horizontal: 165.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Proses',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  } else {
                    return Text('Error calculating total');
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
