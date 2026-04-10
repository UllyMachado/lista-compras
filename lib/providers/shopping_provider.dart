import 'package:flutter/foundation.dart';
import '../models/shopping_item.dart';
import '../models/shopping_list.dart';

class ShoppingProvider with ChangeNotifier {
  final List<ShoppingList> _lists = [
    ShoppingList(id: '1', name: 'Lista Principal')
  ];
  String _currentListId = '1';

  List<ShoppingList> get allLists => List.unmodifiable(_lists);

  ShoppingList get currentList {
    return _lists.firstWhere((l) => l.id == _currentListId, orElse: () => _lists.first);
  }

  double get budget => currentList.budget;
  List<ShoppingItem> get items => List.unmodifiable(currentList.items);

  double get currentBalance {
    double checkedTotal = currentList.items
        .where((item) => item.isChecked)
        .fold(0.0, (sum, item) => sum + item.totalValue);
    return currentList.budget - checkedTotal;
  }

  void createList(String name) {
    if (name.trim().isEmpty) return;
    final newList = ShoppingList(
      id: DateTime.now().toIso8601String(),
      name: name,
    );
    _lists.add(newList);
    _currentListId = newList.id;
    notifyListeners();
  }

  void renameList(String id, String newName) {
    if (newName.trim().isEmpty) return;
    final index = _lists.indexWhere((l) => l.id == id);
    if (index != -1) {
      _lists[index].name = newName;
      notifyListeners();
    }
  }

  void deleteList(String id) {
    if (_lists.length <= 1) return; // Never delete the last list completely
    _lists.removeWhere((l) => l.id == id);
    if (_currentListId == id) {
      _currentListId = _lists.first.id;
    }
    notifyListeners();
  }

  void switchList(String id) {
    if (_lists.any((l) => l.id == id)) {
      _currentListId = id;
      notifyListeners();
    }
  }

  void setBudget(double newValue) {
    currentList.budget = newValue;
    notifyListeners();
  }

  void addItem(ShoppingItem item) {
    currentList.items.add(item);
    notifyListeners();
  }

  void updateItem(int index, ShoppingItem updatedItem) {
    if (index >= 0 && index < currentList.items.length) {
      currentList.items[index] = updatedItem;
      notifyListeners();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < currentList.items.length) {
      currentList.items.removeAt(index);
      notifyListeners();
    }
  }

  void toggleItemCheck(int index) {
    if (index >= 0 && index < currentList.items.length) {
      final item = currentList.items[index];
      currentList.items[index] = item.copyWith(isChecked: !item.isChecked);
      notifyListeners();
    }
  }

  void updateQuantity(int index, double amount) {
    if (index >= 0 && index < currentList.items.length) {
      final item = currentList.items[index];
      double newQuantity = item.quantity + amount;
      if (newQuantity < 1) newQuantity = 1; // Prevent going below 1
      currentList.items[index] = item.copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }
}
