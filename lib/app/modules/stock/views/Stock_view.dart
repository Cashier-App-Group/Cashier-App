import 'package:cashier/app/modules/cashier/controllers/theme_controller.dart';
import 'package:cashier/app/modules/cashier/views/cashier_view.dart';
import 'package:cashier/app/modules/cashier_member/views/cashier_member_view.dart';
import 'package:cashier/app/modules/drawer/controllers/drawer_controller.dart';
import 'package:cashier/app/modules/history/views/history_view.dart';
import 'package:cashier/app/modules/income/views/income_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../discount/views/discount_view.dart';

class DatePage extends StatefulWidget {
  const DatePage({Key? key}) : super(key: key);

  @override
  _DatePickerPageState createState() => _DatePickerPageState();
}

class _DatePickerPageState extends State<DatePage> {
  DateTime? _selectedDate;
  final MyDrawerController drawerController = Get.put(MyDrawerController());
  final GlobalKey<ScaffoldState> _stockScaffoldKey = GlobalKey<ScaffoldState>();
  final ThemeController themeController = Get.put(ThemeController());

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });

      final String dateId = DateFormat('yyyy-MM-dd').format(pickedDate);
      final docRef = FirebaseFirestore.instance.collection('dates').doc(dateId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        await docRef.set({'date': pickedDate});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _stockScaffoldKey,
      appBar: AppBar(
        title: Text('Laporan Stok Harian'),
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('dates').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final dates = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final dateData = dates[index];
                    final String dateId = dateData.id;

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        title: Text(
                          dateId,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 30),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StockPage(dateId: dateId),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: _pickDate,
                child: const Icon(Icons.calendar_today),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StockPage extends StatefulWidget {
  final String dateId;
  const StockPage({Key? key, required this.dateId}) : super(key: key);

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remainingController = TextEditingController();

  Future<void> _addStock() async {
    final String name = _nameController.text;
    final int amount = int.tryParse(_amountController.text) ?? 0;
    final int remaining = int.tryParse(_remainingController.text) ?? 0;

    if (name.isNotEmpty && amount > 0 && remaining >= 0) {
      final stockRef = FirebaseFirestore.instance
          .collection('dates')
          .doc(widget.dateId)
          .collection('stocks');

      await stockRef.add({
        'name': name,
        'amount': amount,
        'remaining': remaining,
      });

      _nameController.clear();
      _amountController.clear();
      _remainingController.clear();
    }
  }

  Future<void> _editStock(String stockId) async {
    final String name = _nameController.text;
    final int amount = int.tryParse(_amountController.text) ?? 0;
    final int remaining = int.tryParse(_remainingController.text) ?? 0;

    if (name.isNotEmpty && amount > 0 && remaining >= 0) {
      final stockRef = FirebaseFirestore.instance
          .collection('dates')
          .doc(widget.dateId)
          .collection('stocks')
          .doc(stockId);

      await stockRef.update({
        'name': name,
        'amount': amount,
        'remaining': remaining,
      });

      _nameController.clear();
      _amountController.clear();
      _remainingController.clear();
    }
  }

  Future<void> _deleteStock(String stockId) async {
    final stockRef = FirebaseFirestore.instance
        .collection('dates')
        .doc(widget.dateId)
        .collection('stocks')
        .doc(stockId);

    await stockRef.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stok pada ${widget.dateId}'),
        backgroundColor: Color(0xFFCD2B21),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('dates')
                  .doc(widget.dateId)
                  .collection('stocks')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stocks = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: stocks.length,
                  itemBuilder: (context, index) {
                    final stock = stocks[index];
                    return GestureDetector(
                      onLongPress: () => _deleteStock(stock.id),
                      onTap: () {
                        _nameController.text = stock['name'];
                        _amountController.text = stock['amount'].toString();
                        _remainingController.text =
                            stock['remaining'].toString();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Edit Stok'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                        labelText: 'Nama Barang'),
                                  ),
                                  TextField(
                                    controller: _amountController,
                                    decoration: const InputDecoration(
                                        labelText: 'Jumlah Stok'),
                                    keyboardType: TextInputType.number,
                                  ),
                                  TextField(
                                    controller: _remainingController,
                                    decoration: const InputDecoration(
                                        labelText: 'Sisa Stok'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    _editStock(stock.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Simpan'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        elevation: 5,
                        child: ListTile(
                          title: Text(stock['name']),
                          subtitle: Text(
                              'Jumlah: ${stock['amount']} | Sisa: ${stock['remaining']}'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _nameController.clear();
          _amountController.clear();
          _remainingController.clear();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Tambah Stok'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Barang'),
                    ),
                    TextField(
                      controller: _amountController,
                      decoration:
                          const InputDecoration(labelText: 'Jumlah Stok'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _remainingController,
                      decoration: const InputDecoration(labelText: 'Sisa Stok'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _addStock();
                      Navigator.pop(context);
                    },
                    child: const Text('Tambah'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
