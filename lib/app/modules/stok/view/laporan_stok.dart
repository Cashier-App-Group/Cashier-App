import 'package:cashier/app/modules/cashier/views/cashier_view.dart';
import 'package:cashier/app/modules/drawer/controllers/drawer_controller.dart';
import 'package:cashier/app/modules/history/views/history_view.dart';
import 'package:cashier/app/modules/income/views/income_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashier/app/modules/stok/view/stok_view.dart' as stokView;

class StockManagementView extends StatefulWidget {
  @override
  _StockManagementViewState createState() => _StockManagementViewState();
}

class _StockManagementViewState extends State<StockManagementView> {
  final List<Map<String, dynamic>> stockData = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final MyDrawerController drawerController = Get.put(MyDrawerController());
  final GlobalKey<ScaffoldState> _stokScaffoldKey = GlobalKey<ScaffoldState>();

  void _addNewStockEntry(String date) async {
    final newStockEntry = {
      'tanggal': date,
      'stokMasuk': 0,
      'stokKeluar': 0,
      'stokAkhir': 0,
      'items': [],
    };

    await firestore.collection('stok').doc(date).set(newStockEntry);
    setState(() {
      stockData.add(newStockEntry);
    });
  }

  Future<void> _showDatePickerDialog() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      _addNewStockEntry(formattedDate);
    }
  }

  Future<void> _fetchStockData() async {
    final snapshot = await firestore.collection('stok').get();
    final List<Map<String, dynamic>> fetchedData = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'tanggal': data['tanggal'] ?? 'Unknown Date',
        'stokMasuk': data['stokMasuk'] ?? 0,
        'stokKeluar': data['stokKeluar'] ?? 0,
        'stokAkhir': data['stokAkhir'] ?? 0,
        'items': data['items'] ?? [],
      };
    }).toList();

    setState(() {
      stockData.clear();
      stockData.addAll(fetchedData);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStockData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _stokScaffoldKey,
      appBar: AppBar(
        title: Text('Manajemen Stok Harian'),
        backgroundColor: Color(0xFFCD2B21),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showDatePickerDialog,
          ),
        ],
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
              onTap: () {
                drawerController.closeDrawer();
                Get.to(() => stokView.StockManagementView());
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
              onTap: () async {
                Get.offAllNamed('/login');
              },
              title: const Text('Logout'),
            ),
          ],
        ),
      ),
      body: stockData.isEmpty
          ? Center(child: Text('No stock entries available.'))
          : ListView.builder(
              itemCount: stockData.length,
              itemBuilder: (context, index) {
                var stock = stockData[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: InkWell(
                      onTap: () {
                        if (stock['tanggal'] != null &&
                            stock['tanggal'].isNotEmpty) {
                          Get.to(() => StockPage(
                                stockId: stock['tanggal'],
                                items: stock['items'],
                              ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Data tanggal tidak valid!')),
                          );
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock['tanggal'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade800,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildStockRow('Stok Masuk:', stock['stokMasuk']),
                          SizedBox(height: 4),
                          _buildStockRow('Stok Keluar:', stock['stokKeluar']),
                          SizedBox(height: 4),
                          _buildStockRow('Stok Akhir:', stock['stokAkhir']),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStockRow(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class StockPage extends StatefulWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String stockId;
  final List<dynamic> items;

  StockPage({Key? key, required this.stockId, required this.items})
      : super(key: key);

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  Future<void> addItemToStock(BuildContext context) async {
    final nameController = TextEditingController();
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Item ke Stok'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nama Item'),
            ),
            TextField(
              controller: stockController,
              decoration: InputDecoration(labelText: 'Jumlah Stok'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final stock = int.tryParse(stockController.text.trim()) ?? 0;
              if (name.isNotEmpty) {
                final updatedItems = [
                  ...widget.items,
                  {'name': name, 'stock': stock}
                ];
                await widget.firestore
                    .collection('stok')
                    .doc(widget.stockId)
                    .update({
                  'items': updatedItems,
                });
                setState(() {
                  widget.items.add({'name': name, 'stock': stock});
                });

                Navigator.of(context).pop();
              }
            },
            child: Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Future<void> removeItemFromStock(int index) async {
    final itemToRemove = widget.items[index];

    final updatedItems = List.from(widget.items)..removeAt(index);
    await widget.firestore
        .collection('stok')
        .doc(widget.stockId)
        .update({'items': updatedItems});

    setState(() {
      widget.items.removeAt(index);
    });
  }

  Future<void> editItemInStock(int index) async {
    final nameController =
        TextEditingController(text: widget.items[index]['name']);
    final stockController =
        TextEditingController(text: widget.items[index]['stock'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Item Stok'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nama Item'),
            ),
            TextField(
              controller: stockController,
              decoration: InputDecoration(labelText: 'Jumlah Stok'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final stock = int.tryParse(stockController.text.trim()) ?? 0;
              if (name.isNotEmpty) {
                final updatedItems = List.from(widget.items)
                  ..[index] = {'name': name, 'stock': stock};
                await widget.firestore
                    .collection('stok')
                    .doc(widget.stockId)
                    .update({
                  'items': updatedItems,
                });
                setState(() {
                  widget.items[index] = {'name': name, 'stock': stock};
                });

                Navigator.of(context).pop();
              }
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Stok'),
        backgroundColor: Colors.red[700],
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          var item = widget.items[index];
          return ListTile(
            title: Text(item['name']),
            subtitle: Text('Jumlah Stok: ${item['stock']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    // Mengedit item
                    editItemInStock(index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Menghapus item
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Hapus Item'),
                        content:
                            Text('Apakah Anda yakin ingin menghapus item ini?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              removeItemFromStock(index);
                              Navigator.of(context).pop();
                            },
                            child: Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addItemToStock(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red[700],
      ),
    );
  }
}
