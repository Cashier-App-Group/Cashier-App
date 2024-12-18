import 'package:cashier/app/modules/cashier/controllers/theme_controller.dart';
import 'package:cashier/app/modules/cashier/views/cashier_view.dart';
import 'package:cashier/app/modules/cashier_member/views/cashier_member_view.dart';
import 'package:cashier/app/modules/drawer/controllers/drawer_controller.dart';
import 'package:cashier/app/modules/history/views/history_view.dart';
import 'package:cashier/app/modules/income/views/income_view.dart';
import 'package:cashier/app/modules/stock/views/Stock_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Discount {
  final String id;
  final String name;
  final double value;
  final bool isPercentage;

  Discount({
    required this.id,
    required this.name,
    required this.value,
    this.isPercentage = false,
  });

  factory Discount.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Discount(
      id: doc.id,
      name: data['name'] ?? '',
      value: (data['value'] ?? 0).toDouble(),
      isPercentage: data['isPercentage'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'isPercentage': isPercentage,
    };
  }
}

class DiscountPage extends StatelessWidget {
  final CollectionReference discountsRef =
      FirebaseFirestore.instance.collection('discounts');
  final MyDrawerController drawerController = Get.put(MyDrawerController());
  final GlobalKey<ScaffoldState> _discountScaffoldKey =
      GlobalKey<ScaffoldState>();
  final ThemeController themeController = Get.put(ThemeController());

  DiscountPage({super.key});

  void _addDiscount() {
    Get.to(() => const AddDiscountPage());
  }

  void _editDiscount(Discount discount) {
    Get.to(() => EditDiscountPage(discount: discount));
  }

  void _deleteDiscount(String id) {
    discountsRef.doc(id).delete();
    Get.snackbar('Hapus Diskon', 'Diskon berhasil dihapus');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _discountScaffoldKey,
      appBar: AppBar(
        title: const Text('Discount Page'),
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
                Get.offAllNamed('/login');
              },
              title: const Text('Logout'),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: discountsRef.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final discounts = snapshot.data!.docs
              .map((doc) => Discount.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: discounts.length,
            itemBuilder: (context, index) {
              final discount = discounts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(discount.name),
                  subtitle: Text(discount.isPercentage
                      ? '${discount.value}%'
                      : 'Rp ${discount.value}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteDiscount(discount.id),
                  ),
                  onTap: () => _editDiscount(discount),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDiscount,
        child: const Icon(Icons.add),
        backgroundColor: Color(0xFFCD2B21),
      ),
    );
  }
}

class AddDiscountPage extends StatefulWidget {
  const AddDiscountPage({super.key});

  @override
  State<AddDiscountPage> createState() => _AddDiscountPageState();
}

class _AddDiscountPageState extends State<AddDiscountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final CollectionReference discountsRef =
      FirebaseFirestore.instance.collection('discounts');

  String _selectedType = 'Persentase';
  final List<String> _types = ['Persentase', 'Nominal'];

  void _saveDiscount() {
    try {
      discountsRef.add({
        'name': _nameController.text,
        'value': double.parse(_valueController.text),
        'isPercentage': _selectedType == 'Persentase',
      });
      Get.snackbar('Tambah Diskon', 'Diskon berhasil ditambahkan');
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan diskon');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Diskon'),
        backgroundColor: Color(0xFFCD2B21),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Diskon',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nilai Diskon',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Tipe Diskon',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedType,
              items: _types.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
              isExpanded: true,
            ),
            const SizedBox(height: 20),

            // Tombol Simpan
            Center(
              child: ElevatedButton(
                onPressed: _saveDiscount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCD2B21),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 12.0),
                ),
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditDiscountPage extends StatelessWidget {
  final Discount discount;

  const EditDiscountPage({super.key, required this.discount});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController =
        TextEditingController(text: discount.name);
    final TextEditingController _valueController =
        TextEditingController(text: discount.value.toString());
    final CollectionReference discountsRef =
        FirebaseFirestore.instance.collection('discounts');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Diskon'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Diskon',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nilai Diskon',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                discountsRef.doc(discount.id).update({
                  'name': _nameController.text,
                  'value': double.parse(_valueController.text),
                });
                Get.snackbar('Edit Diskon', 'Diskon berhasil diperbarui');
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Simpan'),
            )
          ],
        ),
      ),
    );
  }
}
