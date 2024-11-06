import 'package:cashier/app/modules/cashier/controllers/cashier_controller.dart';
import 'package:cashier/app/modules/checkout/views/checkout_view.dart';
import 'package:cashier/app/modules/drawer/controllers/drawer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CashierView extends StatelessWidget {
  final CashierController controller = Get.put(CashierController());
  final MyDrawerController drawerController = Get.put(MyDrawerController());

  // Fungsi untuk mendapatkan gambar berdasarkan nama makanan
  String getFoodImage(String foodName) {
    switch (foodName) {
      case 'Fried Chicken':
        return 'assets/friedchicken.jpg';
      case 'Fried Chicken + Nasi':
        return 'assets/friedchicken dan nasi.jpg';
      case 'F. Chicken+Nasi+Teh':
        return 'assets/friedchicken dan nasi dan teh.jpg';
      case 'Ayam Geprek + Nasi':
        return 'assets/ayam geprek dan nasi.png';
      case 'Geprek+Nasi+Teh':
        return 'assets/ayam geprek dan nasi dan esteh.png';
      case 'Ayam Geprek':
        return 'assets/ayam geprek.png';
      case 'Ayam Sadas':
        return 'assets/sadas.png';
      case 'Ayam Sadas + Nasi':
        return 'assets/sadas dan nasi.jpeg';
      case 'Sadas+Nasi+Teh':
        return 'assets/sadas dan nasi dan esteh.jpeg';
      case 'Nasi Putih':
        return 'assets/nasi.jpg';
      case 'Es Teh/Teh Panas':
        return 'assets/es teh.png';
      case 'Es Jeruk/Panas':
        return 'assets/esjeruk.jpg';
      case 'Es Milo/Milo Panas':
        return 'assets/esmilo.jpg';
      default:
        return 'assets/stok_habis.jpg'; // Gambar default jika tidak ditemukan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: drawerController.scaffoldkey,
      appBar: AppBar(
        title: Text('Menu Makanan'),
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
              onTap: drawerController.closeDrawer,
              title: const Text('Riwayat Pembelian'),
            ),
            ListTile(
              onTap: drawerController.closeDrawer,
              title: const Text('Pemasukan dan Pengeluaran'),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('menu').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            var foodItems = snapshot.data?.docs ?? [];

            return Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari makanan...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onChanged: (value) {
                    // Implement search logic if needed
                  },
                ),
                SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: foodItems.length,
                    itemBuilder: (context, index) {
                      String foodName = foodItems[index]['name'];
                      String foodImage = getFoodImage(foodName);
                      double foodPriceDouble =
                          foodItems[index]['price']?.toDouble() ?? 0.0;
                      String foodPrice = foodPriceDouble > 0
                          ? 'Rp ${foodPriceDouble.toStringAsFixed(2)}'
                          : 'Harga Tidak Tersedia';

                      return Card(
                        elevation: 4.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.asset(
                                foodImage,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 120.0,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                foodName,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              foodPrice,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.green),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    controller.decrement(foodName);
                                  },
                                ),
                                Obx(() => Text(
                                      '${controller.itemCounts[foodName] ?? 0}',
                                      style: TextStyle(fontSize: 18),
                                    )),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    controller.increment(foodName);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Obx(() {
                  if (controller.showCheckoutButton.value) {
                    return Container(
                      margin: EdgeInsets.only(top: 20.0),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFCD2B21),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shopping_cart, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Jumlah Item: ${controller.itemCounts.values.reduce((a, b) => a + b)}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              controller.itemCounts
                                  .forEach((foodName, quantity) {
                                if (quantity > 0) {
                                  controller.addToCheckout(foodName, quantity);
                                }
                              });
                              Get.to(() => CheckoutView());
                            },
                            child: Text('Checkout'),
                          )
                        ],
                      ),
                    );
                  } else {
                    return SizedBox();
                  }
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
