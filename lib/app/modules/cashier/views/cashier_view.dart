import 'package:cashier/app/modules/cashier/controllers/cashier_controller.dart';
import 'package:cashier/app/modules/cashier/controllers/theme_controller.dart';
import 'package:cashier/app/modules/cashier_member/views/cashier_member_view.dart';
import 'package:cashier/app/modules/checkout/views/checkout_view.dart';
import 'package:cashier/app/modules/discount/views/discount_view.dart';
import 'package:cashier/app/modules/drawer/controllers/drawer_controller.dart';
import 'package:cashier/app/modules/event/controllers/event_controller.dart';
import 'package:cashier/app/modules/event/views/event_view.dart';
import 'package:cashier/app/modules/history/views/history_view.dart';
import 'package:cashier/app/modules/income/views/income_view.dart';

import 'package:cashier/app/modules/stock/views/Stock_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CashierView extends StatelessWidget {
  final CashierController controller = Get.put(CashierController());
  final MyDrawerController drawerController = Get.put(MyDrawerController());
  final GlobalKey<ScaffoldState> _cashierScaffoldKey =
      GlobalKey<ScaffoldState>();
  final EventController themeController = Get.put(EventController());
  final PageController _controller = PageController(initialPage: 0);

  var searchQuery = ''.obs;

  String getFoodImage(String foodName) {
    switch (foodName) {
      case 'Fried Chicken':
        return 'assets/friedchicken.jpg';
      case 'F.Chicken + Nasi':
        return 'assets/friedchicken dan nasi.jpg';
      case 'Paket F. Chicken':
        return 'assets/friedchicken dan nasi dan teh.jpg';
      case 'Geprek + Nasi':
        return 'assets/ayam geprek dan nasi.png';
      case 'Paket Geprek':
        return 'assets/ayam geprek dan nasi dan esteh.png';
      case 'Ayam Geprek':
        return 'assets/ayam geprek.png';
      case 'Ayam Sadas':
        return 'assets/sadas.png';
      case 'Ayam Sadas + Nasi':
        return 'assets/sadas dan nasi.jpeg';
      case 'Paket Sadas':
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
        return 'assets/stok_habis.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        key: _cashierScaffoldKey,
        appBar: AppBar(
          title: const Text('Cashier'),
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 30),
                            ),
                            Text(
                              drawerController.userEmail.value,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('menu').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No menu items available.'));
              }

              var foodItems = snapshot.data?.docs ?? [];
              var filteredFoodItems = foodItems.where((foodItem) {
                String foodName = foodItem['name'].toString().toLowerCase();
                return foodName.contains(searchQuery.value.toLowerCase());
              }).toList();
              return Column(
                children: [
                  if (themeController.isIdulFitriTheme.value)
                    SizedBox(
                      height: 200.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: PageView(
                          children: [
                            Image.asset(
                              'assets/ramadhan1.png',
                              fit: BoxFit.cover,
                            ),
                            Image.asset(
                              'assets/ramadhan2.png',
                              fit: BoxFit.cover,
                            ),
                            Image.asset(
                              'assets/ramadhan3.png',
                              fit: BoxFit.cover,
                            ),
                            Image.asset(
                              'assets/ramadhan4.png',
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (themeController.isIdulFitriTheme.value)
                    SmoothPageIndicator(
                      controller: _controller,
                      count: 4, // Jumlah gambar dalam PageView
                      effect: WormEffect(
                        dotWidth: 10.0,
                        dotHeight: 10.0,
                        dotColor: Colors.grey,
                        activeDotColor: Colors.blue,
                      ),
                    ),
                  if (themeController.isKemerdekaanTheme.value)
                    SizedBox(
                      height: 200.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: PageView(
                          children: [
                            Image.asset('assets/kemerdekaan1.png',
                                fit: BoxFit.cover),
                            Image.asset('assets/kemerdekaan2.png',
                                fit: BoxFit.cover),
                            Image.asset('assets/kemerdekaan3.png',
                                fit: BoxFit.cover),
                            Image.asset('assets/kemerdekaan4.png',
                                fit: BoxFit.cover),
                          ],
                        ),
                      ),
                    ),
                  if (themeController.isKemerdekaanTheme.value)
                    SmoothPageIndicator(
                      controller: _controller,
                      count: 4,
                      effect: WormEffect(
                        dotWidth: 10.0,
                        dotHeight: 10.0,
                        dotColor: Colors.grey,
                        activeDotColor: Colors.green,
                      ),
                    ),
                  SizedBox(height: 16.0),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari makanan...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onChanged: (value) {
                      searchQuery.value = value;
                    },
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Obx(() {
                      var filteredFoodItems = foodItems.where((foodItem) {
                        String foodName =
                            foodItem['name'].toString().toLowerCase();
                        return foodName
                            .contains(searchQuery.value.toLowerCase());
                      }).toList();

                      return filteredFoodItems.isEmpty
                          ? Center(
                              child: Text('No food items match your search.'))
                          : GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: filteredFoodItems.length,
                              itemBuilder: (context, index) {
                                String foodName =
                                    filteredFoodItems[index]['name'];
                                String foodImage = getFoodImage(foodName);
                                double foodPriceDouble =
                                    filteredFoodItems[index]['price']
                                            ?.toDouble() ??
                                        0.0;
                                String foodPrice = foodPriceDouble > 0
                                    ? 'Rp ${foodPriceDouble.toStringAsFixed(2)}'
                                    : 'Harga Tidak Tersedia';

                                return Card(
                                  elevation: 4.0,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: 120.0,
                                            minWidth: double.infinity,
                                          ),
                                          child: Image.asset(
                                            foodImage,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          foodName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        foodPrice,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Flexible(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove),
                                              onPressed: () {
                                                controller.decrement(foodName);
                                              },
                                            ),
                                            Obx(() => Text(
                                                  '${controller.itemCounts[foodName] ?? 0}',
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                )),
                                            IconButton(
                                              icon: Icon(Icons.add),
                                              onPressed: () {
                                                controller.increment(foodName);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                    }),
                  ),
                  Obx(() {
                    if (controller.showCheckoutButton.value) {
                      return Container(
                        margin: EdgeInsets.only(top: 20.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: themeController.isKemerdekaanTheme.value
                              ? Color(0xFFe6292f)
                              : themeController.isIdulFitriTheme.value
                                  ? Color(0xFF308c1d)
                                  : Color(0xFFCD2B21),
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
                                    controller.addToCheckout(
                                        foodName, quantity);
                                  }
                                });
                                Get.to(() => CheckoutView());
                              },
                              child: Text('Checkout'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}
