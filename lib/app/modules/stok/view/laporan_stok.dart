import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockPage extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Function to adjust stock by amount
  Future<void> adjustStock(String docId, int adjustment) async {
    DocumentSnapshot doc = await firestore.collection('stock').doc(docId).get();
    int currentStock = (doc.data() as Map<String, dynamic>)['stock'] ?? 0;
    int newStock = currentStock + adjustment;

    await firestore.collection('stock').doc(docId).update({
      'stock': newStock < 0 ? 0 : newStock,
    });
  }

  // Function to add a new stock item
  Future<void> addItem(String name, int stock) async {
    await firestore.collection('stock').add({
      'name': name,
      'stock': stock,
      'createdAt': Timestamp.now(),
    });
  }

  // Function to update stock item name and stock count
  Future<void> updateItem(String docId, String name, int stock) async {
    await firestore.collection('stock').doc(docId).update({
      'name': name,
      'stock': stock,
    });
  }

  // Function to delete a stock item
  Future<void> deleteItem(String docId) async {
    await firestore.collection('stock').doc(docId).delete();
  }

  // Dialog to input item details
  void showItemDialog(BuildContext context, {String? docId, String? name, int? stock}) {
    final nameController = TextEditingController(text: name);
    final stockController = TextEditingController(text: stock?.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? 'Tambah Item' : 'Edit Item'),
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
            onPressed: () {
              final itemName = nameController.text.trim();
              final itemStock = int.tryParse(stockController.text.trim()) ?? 0;

              if (docId == null) {
                addItem(itemName, itemStock);
              } else {
                updateItem(docId, itemName, itemStock);
              }

              Navigator.of(context).pop();
            },
            child: Text(docId == null ? 'Tambah' : 'Update'),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('stock').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Tidak ada item stok.'));
          }

          // Filter for specific items
          var stockItems = snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            var name = data['name']?.toLowerCase() ?? '';
            return name == 'ayam sadas' || name == 'ayam geprek' || name == 'fried chicken';
          }).toList();

          if (stockItems.isEmpty) {
            return Center(child: Text('Tidak ada item stok yang sesuai.'));
          }

          return ListView.builder(
            itemCount: stockItems.length,
            itemBuilder: (context, index) {
              var stockData = stockItems[index].data() as Map<String, dynamic>;
              String docId = stockItems[index].id;
              String itemName = stockData['name'] ?? 'Nama tidak tersedia';
              int itemStock = stockData['stock']?.toInt() ?? 0;

              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text(itemName.substring(0, 2).toUpperCase())),
                ),
                title: Text(
                  itemName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Stok: $itemStock'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: Colors.red),
                      onPressed: () => adjustStock(docId, -1),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.green),
                      onPressed: () => adjustStock(docId, 1),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => showItemDialog(context, docId: docId, name: itemName, stock: itemStock),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteItem(docId),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showItemDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.red[700],
      ),
    );
  }
}
