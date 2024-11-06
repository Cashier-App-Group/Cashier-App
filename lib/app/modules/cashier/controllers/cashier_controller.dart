import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CashierController extends GetxController {
  // Mengelola jumlah item untuk setiap makanan
  var itemCounts = <String, int>{}.obs;
  var checkoutItems = <Map<String, dynamic>>[].obs;
  var showCheckoutButton =
      false.obs; // Untuk mengontrol visibilitas tombol checkout

  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;

  RxList<Map<String, dynamic>> foodItems = <Map<String, dynamic>>[].obs;

  // Menambahkan item ke daftar menu
  Future<void> saveMenuToLocal(List<Map<String, dynamic>> menus) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> menuList = menus.map((menu) {
      return '${menu['name']},${menu['price']},${menu['imagePath']}'; // Menyimpan path gambar lokal
    }).toList();
    await prefs.setStringList('menu', menuList);
  }

  // Fungsi untuk mengambil menu dari SharedPreferences
  Future<List<Map<String, dynamic>>> getMenuFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> menuList = prefs.getStringList('menu') ?? [];
    List<Map<String, dynamic>> menus = menuList.map((menuStr) {
      var menuData = menuStr.split(',');
      return {
        'name': menuData[0],
        'price': double.parse(menuData[1]),
        'imagePath': menuData[2], // Mengambil path gambar lokal
      };
    }).toList();
    return menus;
  }

  // Fungsi untuk memilih gambar menggunakan ImagePicker dan menyimpannya secara lokal
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Pastikan file yang dipilih ada dan valid
      _selectedImage = File(pickedFile.path);
      String imagePath = _selectedImage!.path;

      // Simpan path gambar ke SharedPreferences
      saveImagePathLocally(imagePath);
    } else {
      // Jika tidak ada gambar yang dipilih, tampilkan pesan kesalahan atau beri log
      print('Tidak ada gambar yang dipilih.');
    }
  }

  // Menyimpan path gambar ke SharedPreferences
  Future<void> saveImagePathLocally(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    // Menyimpan path gambar lokal
    await prefs.setString('imagePath', imagePath);
  }

  // Menambahkan item ke daftar checkout
  void addToCheckout(String foodName, int quantity) {
    var itemIndex =
        checkoutItems.indexWhere((item) => item['name'] == foodName);
    if (itemIndex == -1) {
      // Jika item belum ada, tambahkan item baru
      checkoutItems.add({'name': foodName, 'quantity': quantity});
    } else {
      // Jika item sudah ada, perbarui jumlahnya
      checkoutItems[itemIndex]['quantity'] = quantity;
    }
  }

  // Fungsi untuk menambah jumlah item
  void increment(String foodName) {
    if (itemCounts.containsKey(foodName)) {
      itemCounts[foodName] = itemCounts[foodName]! + 1;
    } else {
      itemCounts[foodName] = 1;
    }
    // Update checkoutItems
    addToCheckout(foodName, itemCounts[foodName]!);

    // Perbarui status tombol checkout
    showCheckoutButton.value = itemCounts.values.any((count) => count > 0);
  }

  // Fungsi untuk mengurangi jumlah item
  void decrement(String foodName) {
    if (itemCounts.containsKey(foodName) && itemCounts[foodName]! > 0) {
      itemCounts[foodName] = itemCounts[foodName]! - 1;
    }
    // Update checkoutItems
    if (itemCounts[foodName] == 0) {
      checkoutItems.removeWhere((item) => item['name'] == foodName);
    } else {
      addToCheckout(foodName, itemCounts[foodName]!);
    }

    // Perbarui status tombol checkout
    showCheckoutButton.value = itemCounts.values.any((count) => count > 0);
  }

  // Fungsi untuk checkout
  void checkout() {
    checkoutItems.clear();
    itemCounts.forEach((foodName, quantity) {
      if (quantity > 0) {
        checkoutItems.add({
          'name': foodName,
          'quantity': quantity,
        });
      }
    });
  }
}
