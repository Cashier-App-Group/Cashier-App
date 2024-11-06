import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CashierController extends GetxController {
  var itemCounts = <String, int>{}.obs;
  var checkoutItems = <Map<String, dynamic>>[].obs;
  var showCheckoutButton = false.obs;

  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;

  RxList<Map<String, dynamic>> foodItems = <Map<String, dynamic>>[].obs;

  Future<void> saveMenuToLocal(List<Map<String, dynamic>> menus) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> menuList = menus.map((menu) {
      return '${menu['name']},${menu['price']},${menu['imagePath']}';
    }).toList();
    await prefs.setStringList('menu', menuList);
  }

  Future<List<Map<String, dynamic>>> getMenuFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> menuList = prefs.getStringList('menu') ?? [];
    List<Map<String, dynamic>> menus = menuList.map((menuStr) {
      var menuData = menuStr.split(',');
      return {
        'name': menuData[0],
        'price': double.parse(menuData[1]),
        'imagePath': menuData[2],
      };
    }).toList();
    return menus;
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      String imagePath = _selectedImage!.path;

      saveImagePathLocally(imagePath);
    } else {
      print('Tidak ada gambar yang dipilih.');
    }
  }

  Future<void> saveImagePathLocally(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('imagePath', imagePath);
  }

  void addToCheckout(String foodName, int quantity) {
    var itemIndex =
        checkoutItems.indexWhere((item) => item['name'] == foodName);
    if (itemIndex == -1) {
      checkoutItems.add({'name': foodName, 'quantity': quantity});
    } else {
      checkoutItems[itemIndex]['quantity'] = quantity;
    }
  }

  void increment(String foodName) {
    if (itemCounts.containsKey(foodName)) {
      itemCounts[foodName] = itemCounts[foodName]! + 1;
    } else {
      itemCounts[foodName] = 1;
    }

    addToCheckout(foodName, itemCounts[foodName]!);

    showCheckoutButton.value = itemCounts.values.any((count) => count > 0);
  }

  void decrement(String foodName) {
    if (itemCounts.containsKey(foodName) && itemCounts[foodName]! > 0) {
      itemCounts[foodName] = itemCounts[foodName]! - 1;
    }

    if (itemCounts[foodName] == 0) {
      checkoutItems.removeWhere((item) => item['name'] == foodName);
    } else {
      addToCheckout(foodName, itemCounts[foodName]!);
    }

    showCheckoutButton.value = itemCounts.values.any((count) => count > 0);
  }

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
